module Ironfan
  module Dsl
    class Compute < Ironfan::Dsl::Builder
      @@run_list_rank = 0
      collection :run_list_items, Hash
      collection :clouds,       Ironfan::Dsl::Cloud,    :resolution => ->(f) { merge_resolve(f) }
      collection :volumes,      Ironfan::Dsl::Volume,   :resolution => ->(f) { merge_resolve(f) }
      magic      :environment,  Symbol
      magic      :layer_role,   Ironfan::Dsl::Role,
          :default      => Ironfan::Dsl::Role.new,
          :resolution   => ->(f) { ignore_underlay_resolve(f) }

      # Add the given role/recipe to the run list. You can specify placement of
      # `:first`, `:normal` (or nil) or `:last`; the final runlist is assembled as
      #
      # * run_list :first  items -- cluster, then facet, then server
      # * run_list :normal items -- cluster, then facet, then server
      # * run_list :last   items -- cluster, then facet, then server
      #
      # (see Ironfan::Server#combined_run_list for full details though)
      #
      def role(role_name, placement=nil)
        add_to_run_list("role[#{role_name}]", placement)
      end
      def recipe(recipe_name, placement=nil)
        add_to_run_list(recipe_name, placement)
      end

    protected

      def add_to_run_list(item, placement=nil)
        raise "run_list placement must be one of :first, :normal, :last or nil (also means :normal)" unless [:first, :last, :own, nil].include?(placement)
        placement = :normal if placement.nil?
        @@run_list_rank += 1
        run_list_items[item] = { :name => item, :rank => @@run_list_rank, :placement => placement }
      end

    end
  end
end