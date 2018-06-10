RSpec.describe Site, type: :model do
	REFERENCE_TARGET      = '<div id="content">bar</div>'
	REFERENCE             = "<html><body>foo #{REFERENCE_TARGET}</body></html>"
	CHANGE_OUTSIDE_TARGET = '<html><body>baz <div id="content">bar</div></body></html>'
	CHANGE_TARGET         = '<div id="content">baz</div>'
	CHANGE_INSIDE_TARGET  = "<html><body>foo #{CHANGE_TARGET}</body></html>"

	let :site do
		Site.create! url: 'http://localhost/'
	end

	let :check do
		site.checks.first
	end

	def add_check(**args)
		target = site.targets.create! args
		site.checks.create! target: target
	end

	def stub_page(content)
		allow(Site).to receive(:grab) { OpenStruct.new body: content }
	end

	def check!(content)
		stub_page content
		site.check
	end

	def reference_and_check!(content)
		site.reference! REFERENCE
		self.check! content
	end

	it 'must not change if no change with no check' do
		status = reference_and_check! REFERENCE
		expect(status).to be :unchanged

		expect(site.changed_at).to be_nil
		expect(site.content).to eq REFERENCE
	end

	it 'must not change if no change with checks' do
		check = add_check css: '#content'

		status = reference_and_check! REFERENCE
		expect(status).to be :unchanged

		expect(site.changed_at).to be_nil
		expect(site.content).to eq REFERENCE

		expect(check.changed_at).to be_nil
		expect(check.content).to eq REFERENCE_TARGET
	end

	it 'must change if change with no check' do
		status = reference_and_check! CHANGE_OUTSIDE_TARGET
		expect(status).to be :changed

		expect(site.changed_at).not_to be_nil
		expect(site.content).to eq CHANGE_OUTSIDE_TARGET
	end

	it 'must not change if change but no check changed' do
		check  = add_check css: '#content'
		status = reference_and_check! CHANGE_OUTSIDE_TARGET
		expect(status).to be :unchanged

		expect(site.changed_at).to be_nil
		expect(site.content).to be REFERENCE

		expect(check.changed_at).to be_nil
		expect(check.content).to eq REFERENCE_TARGET
	end

	it 'must change if check changed' do
		check  = add_check css: '#content'
		status = reference_and_check! CHANGE_INSIDE_TARGET
		expect(status).to be :changed

		expect(site.changed_at).not_to be_nil
		expect(site.content).to eq CHANGE_INSIDE_TARGET

		expect(check.changed_at).not_to be_nil
		expect(check.content).to eq CHANGE_TARGET
	end

	it 'must stay changed if no change after a change' do
		first_date  = Date.parse '2018-01-01'
		second_date = first_date + 1
		third_date  = second_date + 1

		Timecop.freeze first_date do
			status = reference_and_check! CHANGE_OUTSIDE_TARGET
			expect(status).to be :changed

			expect(site.changed_at).to eq first_date
			expect(site.content).to eq CHANGE_OUTSIDE_TARGET
		end

		Timecop.freeze second_date do
			status = check! CHANGE_OUTSIDE_TARGET
			expect(status).to be :unchanged

			expect(site.changed_at).to eq first_date
			expect(site.content).to eq CHANGE_OUTSIDE_TARGET
		end

		Timecop.freeze third_date do
			status = check! CHANGE_INSIDE_TARGET
			expect(status).to be :changed

			expect(site.changed_at).to eq third_date
			expect(site.content).to eq CHANGE_INSIDE_TARGET
		end
	end
end
