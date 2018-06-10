
RSpec.describe Site, type: :model do
	REFERENCE = '<html><body>foo <div id="content">bar</div></body></html>'
	CHANGE_OUTSIDE_TARGET = '<html><body>baz <div id="content">bar</div></body></html>'
	CHANGE_INSIDE_TARGET = '<html><body>foo <div id="content">baz</div></body></html>'

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
		site.reference! REFERENCE
		stub_page content
		site.check
	end

	it 'must not change if no change with no check' do
		status = check! REFERENCE
		expect(status).to be :unchanged

		expect(site.changed_at).to be_nil
		expect(site.content).to be_nil
	end

	it 'must not change if no change with checks' do
		check = add_check css: '#content'

		status = check! REFERENCE
		expect(status).to be :unchanged

		expect(site.changed_at).to be_nil
		expect(site.content).to be_nil

		expect(check.changed_at).to be_nil
		expect(check.content).to be_nil
	end

	it 'must change if change with no check' do
		status = check! CHANGE_OUTSIDE_TARGET
		expect(status).to be :changed

		expect(site.changed_at).not_to be_nil
		expect(site.content).not_to be_nil
	end

	it 'must not change if change but no check changed' do
		check = add_check css: '#content'
		status = check! CHANGE_OUTSIDE_TARGET
		expect(status).to be :unchanged

		expect(site.changed_at).to be_nil
		expect(site.content).to be_nil

		expect(check.changed_at).to be_nil
		expect(check.content).to be_nil
	end

	it 'must change if check changed' do
		check = add_check css: '#content'
		status = check! CHANGE_INSIDE_TARGET
		expect(status).to be :changed

		expect(site.changed_at).not_to be_nil
		expect(site.content).not_to be_nil

		expect(check.changed_at).not_to be_nil
		expect(check.content).not_to be_nil
	end
end
