require 'spec_helper'

describe Deploy do
  it { should belong_to(:project) }
end
