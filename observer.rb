module Ruote
  module AuditTrail

    class Observer < Ruote::Observer

      include ReceiverMixin # TODO really needed?

      # On launch, save tree structure (array representation of a
      # Ruote's process) in Ruote's storage.
      #
      def on_msg_launch(msg)
        doc = {
            'type' => 'audit_trail',
            '_id' => msg['wfid'],
            'trail' => msg['tree']
        }

        @context.storage.put(doc)
      end

      # On receive, insert the replied workitem in the audit trail at the proper 
      # location
      #
      def on_pre_msg_receive(msg)
        #return unless accept?(msg) # TODO should use?

        doc = @context.storage.get('audit_trail', msg['fei']['wfid'])
        wi = msg['workitem']

        trail = insert_in_tree(doc['trail'], msg['fei']['expid'], wi['fields'])

        new_doc = {
            'type' => 'audit_trail',
            '_id' => msg['fei']['wfid'],
            '_rev' => doc['_rev'],
            'trail' => trail
        }
        @context.storage.put(new_doc)
      end

      # On terminate, move the audit trail outside Ruote's database
      #
      def on_msg_terminated(msg)
        doc = @context.storage.get('audit_trail', msg['wfid'])

        if doc
          trail = {

              'id' => msg['wfid'],
              'name' => msg['wf_name'],
              'version' => msg['wf_revision'],
              'at' => msg['wf_launched_at'],
              'trail' => doc['trail']
          }

          #db.save(trail)  # TODO Save in the archiving database !
          @context.storage.delete(doc)
        end
      end

      protected

      #def accept?(msg)
      #  msg['type'] == 'msgs'
      #end

      # Insert hash in Ruote's tree based on an expression id.
      #
      def insert_in_tree(tree, exp, fields)
        t = [tree]
        exp = exp.split('_')

        i = 0
        while i < exp.size - 1
          t = t[exp[i].to_i][2] # subtree
          i += 1
        end
        t = t[exp[i].to_i] # last has no subtree

        t[1]['fields'] = fields

        tree
      end

    end
  end
end
RuoteKit.engine.add_service('audit_trail_observer', Ruote::AuditTrail::Observer)
