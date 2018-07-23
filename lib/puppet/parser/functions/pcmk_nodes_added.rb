module Puppet::Parser::Functions
  newfunction(
      :pcmk_nodes_added,
      type: :rvalue,
      arity: -1,
      doc: <<-eof
Input data cluster_members string separated by a space:
* String 'n1 n2 n3'
* Output of `crm_node -l` (only used to ease unit testing) (optional)

Output forms:
* array - output the plain array of nodes that have been added compared
          to the running cluster. It returns an empty array in case the
          cluster is not set up or if crm_node return an error
      eof
  ) do |args|
    nodes = args[0]
    crm_node_list = args[1]
    unless nodes.is_a? String
      fail "Got unsupported nodes input data: #{nodes.inspect}"
    end
    if crm_node_list && !crm_node_list.kind_of?(String) then
      fail "Got unsupported crm_node_list #{crm_node_list.inspect}"
    end

    if crm_node_list && crm_node_list.kind_of?(String) then
      return [] if crm_node_list.empty?
      crm_nodes_output = crm_node_list
    else
      # A typical crm_node -l output is like the following:
      # [root@foobar-0 ~]# crm_node -l
      # 3 foobar-2 member
      # 1 foobar-0 member
      # 2 foobar-1 lost
      crm_nodes_output = `crm_node -l`
      # if the command fails we certainly did not add any nodes
      return [] if $?.exitstatus != 0
    end

    crm_nodes = []
    crm_nodes_output.lines.each { |line|
      (id, node, state, _) = line.split(" ").collect(&:strip)
      valid_states = %w(member lost)
      state.downcase! if state
      crm_nodes.push(node.strip) if valid_states.include? state
    }
    cluster_nodes = nodes.split(" ")
    nodes_added = cluster_nodes - crm_nodes
    Puppet.debug("pcmk_nodes_added: #{nodes_added}")
    nodes_added
  end
end

