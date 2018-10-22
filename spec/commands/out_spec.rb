require 'spec_helper'
require 'open3'
require 'json'

describe "commands:out" do

  let(:out_file) { '/opt/resource/out' }

  it "should exist" do
    expect(File).to exist(out_file)
    expect(File.stat(out_file).mode.to_s(8)[3..5]).to eq("755")
  end

end
