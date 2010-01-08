module RTFM
  class ManPage < Struct.new(:name, :section, :date, :summary, :synopsis, :description)
    class << self
      def text_section(*args)
        args.each do |sect|
          class_eval %Q{
            def #{sect}
              @#{sect} ||= TextSection.new(:#{sect}, "")
            end
            def #{sect}=(str)
              @#{sect} = TextSection.new(:#{sect}, str)
            end
          }
        end
      end
      alias_method :text_sections, :text_section
    end
    
    text_section :bugs, :diagnostics, :compatibility, :standards, :history
    
    def initialize(name, section=nil)
      self.name, self.section = name, section
      self.date = DateTime.now
      self.synopsis = ""
      self.description = ""
      yield self
    end
    
    def see_also
      @see_also ||= SeeAlsoSection.new
      yield @see_also if block_given?
      @see_also
    end
    
    def description
      @description ||= DescriptionSection.new
      yield @description if block_given?
      @description
    end
    
    def to_groff
      GroffString.groffify do |out|
        out.Dd date.strftime("%B %d, %Y")
        out.Os
        out.Dt name, (section || "")
        out.section "NAME"
        out.Nm name
        out.Nd summary
        out.section "SYNOPSIS"
        out << synopsis
        out << @description.to_groff if @description
        out << @see_also.to_groff if @see_also
        out << @history.to_groff if @history
        out << @bugs.to_groff if @bugs
      end
    end
  end
  
end