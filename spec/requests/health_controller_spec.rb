# frozen_string_literal: true

describe 'health' do
  it 'should succeed' do
    expect {
      get '/my_healthcheck'
    }.to output(/Healthcheck passed!/).to_stdout
    expect(response).to have_http_status(:ok)
    expect(json_response).to match(status: 'up')
  end

  it 'should fail' do
    expect {
      get '/my_healthcheck', params: { fail: 'TEST FAIL' }
    }.to output(/Healthcheck failed! TEST FAIL/).to_stdout

    expect(response).to have_http_status(:internal_server_error)

    expect(json_error).to match(
                            status:       'down',
                            message:      'THIS IS A TEST FAILURE',
                            full_message: be_a(String).and(
                              include('THIS IS A TEST FAILURE').and(
                                include('ArgumentError')
                              )
                            )
                          )
  end
end
