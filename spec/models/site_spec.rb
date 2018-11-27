RSpec.describe Site, type: :model do

	context '#check!' do
		REFERENCE_TARGET      = '<div id="content">bar</div>'
		REFERENCE             = "<html><body>foo #{REFERENCE_TARGET}</body></html>"
		CHANGE_OUTSIDE_TARGET = '<html><body>baz <div id="content">bar</div></body></html>'
		CHANGE_TARGET         = '<div id="content">baz</div>'
		CHANGE_INSIDE_TARGET  = "<html><body>foo #{CHANGE_TARGET}</body></html>"

		let :site do
			site           = Site.create! url: 'http://localhost/'
			site.reference = REFERENCE
			site
		end

		let :target do
			site.targets.first
		end

		def expect_changed(content, reference = REFERENCE)
			status = self.check! content
			expect(status).to be :changed
			expect(site.reference).to eq content

			expect(site.changed_at).not_to be_nil

			diffs = site.diffs
			expect(diffs.size).to be 1
			# diff = diffs.first
			#
			# expect(diff.from).to eq reference
			# expect(diff.to).to eq content
		end

		def expect_unchanged(content, changed_at = nil)
			status = self.check! content
			expect(status).to be :unchanged

			expect(site.changed_at).to eq changed_at

			diffs = site.diffs
			expect(diffs.size).to be 0
		end

		def add_target(**args)
			site.targets.create! args
		end

		def stub_page(content)
			allow(site).to receive(:grab) { OpenStruct.new body: content }
		end

		def check!(content)
			stub_page content
			site.diffs.delete_all
			site.check!
		end

		it 'must not change if no change with no target' do
			expect_unchanged REFERENCE
		end

		it 'must not change if no change with target' do
			add_target css: '#content'
			expect_unchanged REFERENCE
		end

		it 'must change if change with no target' do
			expect_changed CHANGE_OUTSIDE_TARGET
		end

		it 'must not change if change but no target changed' do
			add_target css: '#content'
			expect_unchanged CHANGE_OUTSIDE_TARGET
		end

		it 'must change if target changed' do
			add_target css: '#content'
			expect_changed CHANGE_INSIDE_TARGET
		end

		it 'must stay changed if no change after a change' do
			first_date  = Date.parse '2018-01-01'
			second_date = first_date + 1
			third_date  = second_date + 1

			Timecop.freeze first_date do
				expect_changed CHANGE_OUTSIDE_TARGET
			end

			Timecop.freeze second_date do
				expect_unchanged CHANGE_OUTSIDE_TARGET, first_date
			end

			Timecop.freeze third_date do
				expect_changed CHANGE_INSIDE_TARGET, CHANGE_OUTSIDE_TARGET
			end
		end
	end
end
