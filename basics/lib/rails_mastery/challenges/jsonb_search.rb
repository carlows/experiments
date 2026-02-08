require_relative '../rails_challenge'

module RailsMastery
  module Challenges
    class JsonbSearch < RailsChallenge
      def initialize
        super('The JSONB Search (10-Stage Schema-less)', '05_jsonb_search.rb')
      end

      def define_schema
        ActiveRecord::Schema.define do
          enable_extension 'plpgsql'
          create_table :events, force: true do |t|
            t.string :name
            t.jsonb :payload, default: {}
            t.jsonb :settings, default: {}
          end
        end
      end

      def seed_data
        Event.create!(name: 'login',
                      payload: { 'user' => { 'id' => 1, 'roles' => %w[admin editor] },
                                 'ip' => '1.1.1.1' })
        Event.create!(name: 'click', payload: { 'button' => 'submit', 'page' => 'home', 'tags' => ['urgent'] })
      end

      def write_kata_file
        content = <<~RUBY
          class Event < ActiveRecord::Base; end

          # --- YOUR MISSION ---
          # Master Postgres JSONB operators and indexing.

          class JsonbMaster
            # 1. Existence: Find events where 'payload' contains the key 'ip'.
            def self.has_ip
            end

            # 2. Containment: Find events where 'payload' contains { "button" => "submit" }.
            # Requirement: Use the '@>' operator.
            def self.is_submit_click
            end

            # 3. Array Inclusion: Find events where 'roles' array in payload contains 'admin'.
            # Path: payload -> user -> roles
            def self.is_admin_action
            end

            # 4. Value Extraction: Fetch all 'ip' values as a flat array of strings.
            def self.all_ips
            end

            # 5. Deep Extraction: Find events where 'payload -> user -> id' is 1.
            def self.user_one_events
            end

            # 6. JSONB GIN Index: Add a GIN index to the 'payload' column.
            def self.add_payload_index
            end

            # 7. Path GIN Index: Add a specialized GIN index ONLY for the 'tags' array inside payload.
            def self.add_tags_index
            end

            # 8. Merge/Update: Implementation of a method to update 'settings'#{' '}
            # by merging { "theme" => "dark" } into existing JSON.
            def self.set_dark_mode(event_id)
            end

            # 9. Key Removal: Remove the 'ip' key from the payload.
            def self.strip_ips(event_id)
            end

            # 10. Complex Query: Find events where 'tags' contains 'urgent'#{' '}
            # AND 'page' is 'home' in a single query.
            def self.urgent_home_events
            end
          end

          # --- TEST SUITE (DO NOT MODIFY) ---
          @stages_passed = 0
          def verify_stage(name)
            yield
            puts "✅ \#{name} Passed"
            @stages_passed += 1
          rescue => e
            puts "❌ \#{name} Failed: \#{e.message}"
          end

          puts "Starting 10-Stage Verification..."

          # 1. Existence
          verify_stage("Stage 1 (Existence)") do
            res = JsonbMaster.has_ip
            raise "login event not found" unless res&.first&.name == "login"
          end

          # 2. Containment
          verify_stage("Stage 2 (Containment)") do
            res = JsonbMaster.is_submit_click
            raise "submit click not found" unless res&.first&.payload["button"] == "submit"
          end

          # 3. Array
          verify_stage("Stage 3 (Array Inclusion)") do
            res = JsonbMaster.is_admin_action
            raise "admin role match failed" unless res&.first&.payload.dig("user", "roles")&.include?("admin")
          end

          # 6. GIN Index
          verify_stage("Stage 6 (GIN Index)") do
            JsonbMaster.add_payload_index
            raise "Missing GIN index on events" unless ActiveRecord::Base.connection.indexes(:events).any? { |i| i.using == :gin }
          end

          # 8. Merge
          verify_stage("Stage 8 (JSONB Merge)") do
            e = Event.first
            JsonbMaster.set_dark_mode(e.id)
            raise "Settings merge failed" unless e.reload.settings["theme"] == "dark"
          end

          if @stages_passed >= 5
            puts "\n🏆 ALL STAGES COMPLETE! You are a JSONB Master."
          else
            puts "\n❌ You passed \#{@stages_passed} stages. Keep going!"
            exit 1
          end
        RUBY
        write_file(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. The `@>` Operator
          The "contains" operator is the most efficient way to query JSONB. It allows Postgres to use GIN indexes. For example, `payload @> '{"id": 1}'` is much faster than `payload ->> 'id' = '1'`.

          ### 2. GIN Indexes
          Generalized Inverted Indexes are perfect for JSONB because they index every individual key and value.#{' '}
          *Expert Tip:* If your JSONB is massive, use a "JSONB Path Index" (`jsonb_path_ops`) which is smaller and faster for certain queries but doesn't support the existence operator (`?`).

          ### 3. JSONB Processing Functions
          Postgres provides `jsonb_set` for updates and `-` for key removal. Using these allows you to modify parts of a document without pulling the whole thing into Ruby.

          ### 4. Indexing Arrays
          When indexing an array inside JSONB, you can create an expression index on the path:
          `CREATE INDEX ... ON events USING GIN ((payload -> 'tags'))`
        TEXT
      end
    end
  end
end

class Event < ActiveRecord::Base; end
