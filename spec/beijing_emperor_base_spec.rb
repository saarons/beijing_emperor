require File.join(File.dirname(__FILE__),'spec_helper.rb')

describe "The bank account class" do
  before do
    BeijingEmperor::Base.database.clear
    @bank  = Bank.new(:name => "Wells Fargo", :code => 4)
    @bank2 = Bank.new(:name => "Citi",        :code => 2)
    @bank.save
    @bank2.save    
  end
  
  it "has a friendly name" do
    Bank.friendly_name.should == "bank"
  end
  
  it "will find a specific bank" do
    Bank.find(@bank.id).should == @bank
    Bank.find([@bank.id]).should == [@bank]
  end
  
  it "will find all banks" do
    Bank.all.should == [@bank, @bank2]
    Bank.find(:all).should == [@bank, @bank2]
  end
  
  it "will find the first bank" do
    Bank.first.should == @bank
    Bank.find(:first).should == @bank
  end
  
  it "will find the last bank" do
    Bank.last.should == @bank2
    Bank.find(:last).should == @bank2
  end
  
  it "will find all with conditions" do
    Bank.find(:all, :conditions => {:name => "Wells Fargo"}).should == [@bank]
    Bank.find(:all, :conditions => {:name => ["==","Wells Fargo"]}).should == [@bank]
    Bank.find(:all, :conditions => {:name => ["!=","Wells Fargo"]}).should_not include @bank
  end
  
  it "will find all with (between) conditions" do
    Bank.find(:all, :conditions => {:code => 1..5}).should == [@bank, @bank2]
    Bank.find(:all, :conditions => {:code => ["><", "1 5"]}).should == [@bank, @bank2]
    Bank.find(:all, :conditions => {:code => ["<>", 1..3]}).should_not include @bank2
    Bank.find(:all, :conditions => {:code => ["<>", "1 3"]}).should_not include @bank2    
  end
  
  it "will find all with (equal number) conditions" do
    Bank.find(:all, :conditions => {:code => ["==", 4]}).should == [@bank]
  end
end

describe "A bank account instance" do
  before do
    @bank = Bank.new(:name => "Wells Fargo", :code => 4)
  end
  
  after do
    BeijingEmperor::Base.database.clear
  end
  
  it "has read accessors" do
    @bank.name.should == "Wells Fargo"
    @bank.attributes[:name].should == "Wells Fargo"    
  end
  
  it "has write accessors" do
    @bank.name = "Chase"
    @bank.name.should == "Chase"
    @bank.attributes[:name].should == "Chase"    
  end
  
  context "that is unsaved" do
    it "can not be destroyed" do
      @bank.destroy.should be_false
    end
  end
  
  context "that is valid" do
    it "will save" do
      @bank.save.should be_true
      lambda { @bank.save! }.should be_true
    end
  end
  
  context "that is invalid" do
    before do
      @bank = Bank.new(:code => 8)
    end
    
    it "will not save" do
      @bank.save.should be_false
      lambda { @bank.save! }.should raise_error BeijingEmperor::RecordNotSaved
    end
  end
  
  context "that is saved" do
    before do
      @bank.save
    end
    
    it "can be destroyed" do
      @bank.destroy.should be_true
    end
  end
end
