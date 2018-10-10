require 'spec_helper'

describe "commands:in" do

  let(:in_file) { '/opt/resource/in' }

  it('should exist') do
    expect(File).to exist(in_file)
    expect(File.stat(in_file).mode.to_s(8)[3..5]).to eq("755")
  end

  it('should return an empty version') do
    expect(`#{in_file}`).to eq("{\"version\":{}}\n")
  end

end
