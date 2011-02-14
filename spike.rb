#!/usr/bin/env ruby

# TODO: support backward input lines
# TODO: overlapping labels for external guidances/mechanisms
# TODO: alert reader to issues with the model, such as an input that is received but not produced by any process
# TODO: sharing external concepts (they appear twice currently)
# TODO: unbundling
# TODO: Resize boxes to accommodate anchor points
# TODO: Remove alias #process for Diagram#box

require_relative 'lib/idef0/statement'
require_relative 'lib/idef0/diagram'

class Object

  def inspect
    object_id
  end

end

statements = IDEF0::Statement.parse($<.read)

diagram_names = statements.select{ |s| s.predicate == "is composed of" }.map(&:subject).uniq
raise "One root process required (#{diagram_names.inspect})" if diagram_names.count != 1

diagram = IDEF0.diagram(diagram_names.first) do |diagram|
  statements.each do |statement|
    case statement.predicate
    when "is composed of"
      # diagram.box(statement.object)
    when "receives", "produces", "respects", "requires"
      if statement.subject == diagram.name
        diagram.send(statement.predicate, statement.object)
      else
        diagram.box(statement.subject) do |box|
          box.send(statement.predicate, statement.object)
        end
      end
    end
  end
end

puts diagram.to_svg
