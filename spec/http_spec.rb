RSpec.describe Http do
	let :site do
		Http.new 'http://localhost/'
	end

	it 'must encode to utf-8 if not HTML' do
		stub_request(:any, 'localhost').to_return body:    "\xC3\xA9", status: 200,
												  headers: { 'Content-Type': 'application/pdf' }
		expect(site.body.encoding).to eq Encoding::UTF_8
		expect(site.body).to eq "\xC3\xA9"
	end

	it 'must encode to utf-8 if HTML and nothing specified' do
		body = <<-HEREDOC
			<html>
				<body>\xC3\xA9</body>
			</html>'
		HEREDOC
		stub_request(:any, 'localhost').to_return body:    body, status: 200,
												  headers: { 'Content-Type': 'text/html' }
		body = site.body
		expect(body.encoding).to eq Encoding::UTF_8
		body = Nokogiri::HTML.parse body
		body = body.at('body').content
		expect(body).to eq "\xC3\xA9"
	end

	it 'must encode to given content-type charset if nothing specified' do
		body = <<-HEREDOC
			<html>
				<body>\xE9</body>
			</html>'
		HEREDOC
		stub_request(:any, 'localhost').to_return body:    body, status: 200,
												  headers: { 'Content-Type': 'text/html; charset=iso-8859-1' }
		body = site.body
		expect(body.encoding).to eq Encoding::UTF_8
		body = Nokogiri::HTML.parse body
		body = body.at('body').content
		expect(body).to eq "\xC3\xA9"
	end

	it 'must encode to given meta charset' do
		body = <<-HEREDOC
			<html>
				<head>
					<meta charset="ISO-8859-1"/>
				</head>
				<body>\xE9</body>
			</html>'
		HEREDOC
		stub_request(:any, 'localhost').to_return body:    body, status: 200,
												  headers: { 'Content-Type': 'text/html' }
		body = site.body
		expect(body.encoding).to eq Encoding::UTF_8
		body = Nokogiri::HTML.parse body
		body = body.at('body').content
		expect(body).to eq "\xC3\xA9"
	end

	it 'must encode to given meta http-equiv' do
		body = <<-HEREDOC
			<html>
				<head>
					<meta http-equiv="Content-Type" content="text/html; CHARSET=iso-8859-1">
				</head>
				<body>\xE9</body>
			</html>'
		HEREDOC
		stub_request(:any, 'localhost').to_return body:    body, status: 200,
												  headers: { 'Content-Type': 'text/html' }
		body = site.body
		expect(body.encoding).to eq Encoding::UTF_8
		body = Nokogiri::HTML.parse body
		body = body.at('body').content
		expect(body).to eq "\xC3\xA9"
	end
end
