module Pacemaker
  # function related to the primitives configuration
  # main structure "primitives"
  module Primitives
    # get all 'primitive' sections from CIB
    # @return [Array<REXML::Element>] at /cib/configuration/resources/primitive
    def cib_section_primitives
      REXML::XPath.match cib, '//primitive'
    end

    # sets the meta attribute of a primitive
    # @param primitive [String] primitive's id
    # @param attribute [String] atttibute's name
    # @param value [String] attribute's value
    def set_primitive_meta_attribute(primitive, attribute, value)
      options = ['--quiet', '--resource', primitive]
      options += ['--set-parameter', attribute, '--meta', '--parameter-value', value]
      retry_block { crm_resource_safe options }
    end

    # disable this primitive
    # @param primitive [String] what primitive to disable
    def disable_primitive(primitive)
      set_primitive_meta_attribute primitive, 'target-role', 'Stopped'
    end

    alias stop_primitive disable_primitive

    # enable this primitive
    # @param primitive [String] what primitive to enable
    def enable_primitive(primitive)
      set_primitive_meta_attribute primitive, 'target-role', 'Started'
    end

    alias start_primitive enable_primitive

    # manage this primitive
    # @param primitive [String] what primitive to manage
    def manage_primitive(primitive)
      set_primitive_meta_attribute primitive, 'is-managed', 'true'
    end

    # unmanage this primitive
    # @param primitive [String] what primitive to unmanage
    def unmanage_primitive(primitive)
      set_primitive_meta_attribute primitive, 'is-managed', 'false'
    end

    # ban this primitive
    # @param primitive [String] what primitive to ban
    # @param node [String] on which node this primitive should be banned
    def ban_primitive(primitive, node)
      options = ['--quiet', '--resource', primitive, '--node', node]
      options += ['--ban']
      retry_block { crm_resource_safe options }
    end

    # unban this primitive
    # @param primitive [String] what primitive to unban
    # @param node [String] on which node this primitive should be unbanned
    def unban_primitive(primitive, node)
      options = ['--quiet', '--resource', primitive, '--node', node]
      options += ['--clear']
      retry_block { crm_resource_safe options }
    end

    alias clear_primitive unban_primitive

    # move this primitive
    # @param primitive [String] what primitive to un-move
    # @param node [String] to which node the primitive should be moved
    def move_primitive(primitive, node)
      options = ['--quiet', '--resource', primitive, '--node', node]
      options += ['--move']
      retry_block { crm_resource_safe options }
    end

    # un-move this primitive
    # @param primitive [String] what primitive to un-move
    # @param node [String] from which node the primitive should be un-moved
    def unmove_primitive(primitive, node)
      options = ['--quiet', '--resource', primitive, '--node', node]
      options += ['--un-move']
      retry_block { crm_resource_safe options }
    end

    # cleanup this primitive
    # @param primitive [String] what primitive to cleanup
    # @param node [String] on which node to cleanup (optional)
    # cleanups on every node if node is not given
    def cleanup_primitive(primitive, node = nil)
      options = ['--quiet', '--resource', primitive]
      options += ['--node', node] if node
      options += ['--cleanup']
      retry_block { crm_resource_safe options }
    end

    # the list of complex types the library should
    # read from the CIB and parse their meta-data
    # @return [Array<String>]
    def read_complex_types
      %w(clone master group)
    end

    # the list of complex type the library should
    # be able to create XML elements for
    # @return [Array<String>]
    def write_complex_types
      %w(clone master)
    end

    ##############################################################################

    # get primitives configuration structure with primitives and their attributes
    # @return [Hash<String => Hash>]
    def primitives
      return @primitives_structure if @primitives_structure
      @primitives_structure = {}
      cib_section_primitives.each do |primitive|
        id = primitive.attributes['id']
        next unless id
        primitive_structure = attributes_to_hash primitive
        primitive_structure.store 'name', id

        if read_complex_types.include?(primitive.parent.name) && primitive.parent.attributes['id']
          complex_structure = {
              'id' => primitive.parent.attributes['id'],
              'type' => primitive.parent.name
          }

          complex_meta_attributes = primitive.parent.elements['meta_attributes']
          if complex_meta_attributes
            complex_meta_attributes_structure = children_elements_to_hash complex_meta_attributes, 'name', 'nvpair'
            complex_structure.store 'meta_attributes', complex_meta_attributes_structure
          end

          primitive_structure.store 'name', complex_structure['id'] unless complex_structure['type'] == 'group'
          primitive_structure.store 'complex', complex_structure
        end

        instance_attributes = primitive.elements['instance_attributes']
        if instance_attributes
          instance_attributes_structure = children_elements_to_hash instance_attributes, 'name', 'nvpair'
          primitive_structure.store 'instance_attributes', instance_attributes_structure
        end

        meta_attributes = primitive.elements['meta_attributes']
        if meta_attributes
          meta_attributes_structure = children_elements_to_hash meta_attributes, 'name', 'nvpair'
          primitive_structure.store 'meta_attributes', meta_attributes_structure
        end

        operations = primitive.elements['operations']
        if operations
          operations_structure = parse_operations operations
          primitive_structure.store 'operations', operations_structure
        end

        @primitives_structure.store id, primitive_structure
      end
      @primitives_structure
    end

    # parse the operations structure of a primitive
    # @param operations_element [REXML::Element]
    # @return [Hash]
    def parse_operations(operations_element)
      return unless operations_element.is_a? REXML::Element
      operations = {}
      ops = operations_element.get_elements 'op'
      return operations unless ops.any?
      ops.each do |op|
        op_structure = attributes_to_hash op
        id = op_structure['id']
        next unless id
        instance_attributes = op.elements['instance_attributes']
        if instance_attributes
          instance_attributes_structure = children_elements_to_hash instance_attributes, 'name', 'nvpair'
          if instance_attributes_structure.key? 'OCF_CHECK_LEVEL'
            value = instance_attributes_structure.fetch('OCF_CHECK_LEVEL', {}).fetch('value', nil)
            op_structure['OCF_CHECK_LEVEL'] = value if value
          end
        end
        operations.store id, op_structure
      end
      operations
    end

    # check if primitive exists in the configuration
    # @param primitive primitive id or name
    def primitive_exists?(primitive)
      primitives.key? primitive
    end

    # return primitive class
    # @param primitive [String] primitive id
    # @return [String,nil] primitive class
    def primitive_class(primitive)
      return unless primitive_exists? primitive
      primitives[primitive]['class']
    end

    # return primitive type
    # @param primitive [String] primitive id
    # @return [String,nil] primitive type
    def primitive_type(primitive)
      return unless primitive_exists? primitive
      primitives[primitive]['type']
    end

    # return primitive provider
    # @param primitive [String] primitive id
    # @return [String,nil] primitive type
    def primitive_provider(primitive)
      return unless primitive_exists? primitive
      primitives[primitive]['provider']
    end

    # return primitive complex type
    # or nil is the primitive is simple
    # @param primitive [String] primitive id
    # @return [Symbol] primitive complex type
    def primitive_complex_type(primitive)
      return unless primitive_is_complex? primitive
      primitives[primitive]['complex']['type'].to_sym
    end

    # return the full name of the complex primitive
    # or just a name for a simple primitive
    # @return [String] primitive type
    def primitive_full_name(primitive)
      return unless primitive_exists? primitive
      primitives[primitive]['name']
    end

    # check if primitive is clone or master
    # primitives in groups are not considered complex
    # despite having the complex structure
    # @param primitive [String] primitive id
    # @return [TrueClass,FalseClass]
    def primitive_is_complex?(primitive)
      return unless primitive_exists? primitive
      return false unless primitives[primitive].key? 'complex'
      primitives[primitive]['complex']['type'] != 'group'
    end

    # reverse of the complex? predicate
    # but returns nil if resource doesn't exist
    # @param primitive [String] primitive id
    # @return [TrueClass,FalseClass]
    def primitive_is_simple?(primitive)
      return unless primitive_exists? primitive
      ! primitive_is_complex?(primitive)
    end

    # check if the primitive is assigned to a group
    # @param primitive [String] primitive id
    # @return [TrueClass,FalseClass]
    def primitive_in_group?(primitive)
      return unless primitive_exists? primitive
      return false unless primitives[primitive].key? 'complex'
      primitives[primitive]['complex']['type'] == 'group'
    end

    # get the group name of the primitive
    # returns nil if primitive is not in a group
    # @return [String,nil] primitive group
    def primitive_group(primitive)
      return unless primitive_in_group? primitive
      primitives[primitive]['complex']['id']
    end

    # check if primitive is clone
    # @param primitive [String] primitive id
    # @return [TrueClass,FalseClass]
    def primitive_is_clone?(primitive)
      is_complex = primitive_is_complex? primitive
      return is_complex unless is_complex
      primitives[primitive]['complex']['type'] == 'clone'
    end

    # check if primitive is master
    # @param primitive [String] primitive id
    # @return [TrueClass,FalseClass]
    def primitive_is_master?(primitive)
      is_complex = primitive_is_complex? primitive
      return is_complex unless is_complex
      primitives[primitive]['complex']['type'] == 'master'
    end

    # determine if primitive is managed
    # @param primitive [String] primitive id
    # @return [TrueClass,FalseClass]
    def primitive_is_managed?(primitive)
      return unless primitive_exists? primitive
      is_managed = primitives.fetch(primitive).fetch('meta_attributes', {}).fetch('is-managed', {}).fetch('value', 'true')
      is_managed == 'true'
    end

    # determine if primitive has target-state started
    # @param primitive [String] primitive id
    # @return [TrueClass,FalseClass]
    def primitive_is_started?(primitive)
      return unless primitive_exists? primitive
      target_role = primitives.fetch(primitive).fetch('meta_attributes', {}).fetch('target-role', {}).fetch('value', 'Started')
      target_role == 'Started'
    end

    # generate a new XML element object
    # and fill it with the primitive data from
    # the provided primitive structure
    # @param data [Hash] primitive_structure
    # @return [REXML::Element]
    def xml_primitive(data)
      raise "Primitive data should be a hash! Got: #{data.inspect}" unless data.is_a? Hash
      primitive_skip_attributes = %w(name parent instance_attributes operations meta_attributes utilization)
      primitive_element = xml_element 'primitive', data, primitive_skip_attributes

      # instance attributes
      if data['instance_attributes'].respond_to?(:each) && data['instance_attributes'].any?
        instance_attributes_document = xml_document 'instance_attributes', primitive_element
        instance_attributes_document.add_attribute 'id', data['id'] + '-instance_attributes'
        sort_data(data['instance_attributes']).each do |instance_attribute|
          instance_attribute_element = xml_element 'nvpair', instance_attribute
          instance_attributes_document.add_element instance_attribute_element if instance_attribute_element
        end
      end

      # meta attributes
      if data['meta_attributes'].respond_to?(:each) && data['meta_attributes'].any?
        complex_meta_attributes_document = xml_document 'meta_attributes', primitive_element
        complex_meta_attributes_document.add_attribute 'id', data['id'] + '-meta_attributes'
        sort_data(data['meta_attributes']).each do |meta_attribute|
          meta_attribute_element = xml_element 'nvpair', meta_attribute
          complex_meta_attributes_document.add_element meta_attribute_element if meta_attribute_element
        end
      end

      # operations
      if data['operations'].respond_to?(:each) && data['operations'].any?
        operations_document = xml_document 'operations', primitive_element
        sort_data(data['operations']).each do |operation|
          operation_element = xml_element 'op', operation, %w(OCF_CHECK_LEVEL)
          if operation.key? 'OCF_CHECK_LEVEL'
            instance_attributes_document = xml_document 'instance_attributes', operation_element
            instance_attributes_id = operation['id'] + '-instance_attributes'
            instance_attributes_document.add_attribute 'id', instance_attributes_id
            ocf_check_level_id = instance_attributes_id + '-OCF_CHECK_LEVEL'
            ocf_check_level_structure = {
                'id' => ocf_check_level_id,
                'name' => 'OCF_CHECK_LEVEL',
                'value' => operation['OCF_CHECK_LEVEL'],
            }
            ocf_check_level_element = xml_element 'nvpair', ocf_check_level_structure
            instance_attributes_document.add_element ocf_check_level_element if ocf_check_level_element
          end
          operations_document.add_element operation_element if operation_element
        end
      end

      # complex structure
      if data['complex'].is_a?(Hash) && write_complex_types.include?(data['complex']['type'].to_s)
        skip_complex_attributes = 'type'
        complex_tag_name = data['complex']['type'].to_s
        complex_element = xml_element complex_tag_name, data['complex'], skip_complex_attributes

        # complex meta attributes
        if data['complex']['meta_attributes'].respond_to?(:each) && data['complex']['meta_attributes'].any?
          complex_meta_attributes_document = xml_document 'meta_attributes', complex_element
          complex_meta_attributes_document.add_attribute 'id', data['complex']['id'] + '-meta_attributes'
          sort_data(data['complex']['meta_attributes']).each do |meta_attribute|
            complex_meta_attribute_element = xml_element 'nvpair', meta_attribute
            complex_meta_attributes_document.add_element complex_meta_attribute_element if complex_meta_attribute_element
          end
        end

        complex_element.add_element primitive_element
        return complex_element
      end

      primitive_element
    end
  end
end
