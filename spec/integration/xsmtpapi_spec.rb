require "spec_helper"

describe 'X-SMTPAPI compatibility' do
  describe "xsmtpapi for bulk" do
    # This should guarantee the expected behavior for the following api:
    #   http://sendgrid.com/docs/API_Reference/SMTP_API/unique_arguments.html
    context "generates expected xsmtpapi for #post!" do
      let(:envelope) { build(:envelope_multi, xsmtpapi: { "sub" => { "-email-id-" => ["314159","271828"] }, "unique_args" => { "email_id" => "-email-id-"} }) }
      let(:expectated_hash) { {"sub"=>{"-email-id-"=>["314159", "271828"], "*|NAME|*"=>["Mail Cannon", "Lucas Martins", "Contact"], "*|EMAIL|*"=>["mailcannon@railsnapraia.com", "lucasmartins@railsnapraia.com", "contact@railsonthebeach.com"]}, "unique_args"=>{"email_id"=>"-email-id-", "envelope_id"=>envelope.id}, "to"=>["mailcannon@railsnapraia.com", "lucasmartins@railsnapraia.com", "contact@railsonthebeach.com"]} }

      it "returns true" do
        VCR.use_cassette('mailcannon_adapter_sendgrid_send_bulk') do
          Sidekiq::Testing.inline! do
            envelope.post!
          end
        end
        envelope.save
        envelope.reload # content is changed inside the Adapter module
        expect(envelope.xsmtpapi).to eq(expectated_hash)
      end
    end
  end
end
