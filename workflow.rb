module Ruote

  # Reopen to add era
  #
  class Workitem
    
    def era
      @era ||= :present
    end

    def active?() era == :present end
    def disabled?() era != :present end

    def past?() era == :past end
    def now?() era == :present end # present? is used by Module
    def future?() era == :future end
    
  end
end

module Workflow
  class PastWorkitem < Ruote::Workitem
    def initialize(exp)

      @era = :past
      h = {'participant_name' => exp[0], 'fields' => exp[1]['fields']}
      super(h)
    end
  end

  class FutureWorkitem < Ruote::Workitem
    def initialize(exp)

      @era = :future
      h = {'participant_name' => exp[0], 'fields' => {'params' => exp[1]}}
      super(h)
    end
  end

  #class If
  #  def initialize()
  #  end
  #end

  class Tree
    @future = false

    def self.from_workitem(wi)

      @workitem = wi
      doc = RUOTE_STORAGE.get('audit_trail', @workitem.fei.wfid) # TODO Shouldn't AuditTrail module do this?

      branch('0', doc['trail'][2][0])
    end

    protected

    def self.branch(expid, exp)

      # Deals with ruote language constructs
      construct = %w(sequence concurrence) # TODO Manage concurrence, if, etc

      # TODO This should be a Factory
      if construct.include? exp[0]
        children(expid, exp)

      else
        new_workitem(expid, exp)

      end
    end

    def self.children(expid, exp)

      i = -1
      ret = exp[2].collect do |child|
        i += 1
        branch("#{expid}_#{i}", child)
      end
    end

    def self.new_workitem(expid, exp)
      case find_era(expid)
        when :present
          @workitem
        when :past
          PastWorkitem.new(exp)
        when :future
          FutureWorkitem.new(exp)
      end
    end

    def self.find_era expid
      if @workitem.fei.expid == "0_" + expid # TODO get rid of "0_" ?!
        @future = true
        :present

      elsif @future
        :future

      else
        :past
      end
    end
  end
end
