require "test_helper"

class BeijingEmperorTest < Test::Unit::TestCase
  def setup
    BeijingEmperor::Base.database.clear
    @bank = Bank.new(:name => "Wells Fargo")
    @credit_union = CreditUnion.new(:name => "San Jose Credit Union")
  end

  def test_connection
    BeijingEmperor::Base.database.should_not be_nil
  end

  def test_read_accessors
    @bank.name.should == "Wells Fargo"
    @bank.attributes[:name].should == "Wells Fargo"
  end

  def test_write_accessors
    @bank.name = "Chase"
    @bank.name.should == "Chase"
    @bank.attributes[:name].should == "Chase" 
  end

  def test_block_constructor
    bank = Bank.new do |b|
      b.name = "Wells Fargo"
    end
    @bank.name.should == "Wells Fargo"
    @bank.attributes[:name].should == "Wells Fargo"
  end

  def test_subclass_read_accessors
    @credit_union.name.should == "San Jose Credit Union"
    @credit_union.attributes[:name].should == "San Jose Credit Union"
  end

  def test_subclass_write_accessors
    @credit_union.name = "Phoenix Credit Union"
    @credit_union.name.should == "Phoenix Credit Union"
    @credit_union.attributes[:name].should == "Phoenix Credit Union"
  end

  def test_save
    @bank.save.should be true
  end

  def test_save!
    @bank.save!.should be true
  end

  def test_destroy
    @bank.destroy.should be false
    @bank.save.should be true
    @bank.destroy.should be true
  end

  def test_friendly_name
    Bank.friendly_name.should == "bank"
  end

  def test_subclass_friendly_name
    CreditUnion.friendly_name.should == "credit_union"
  end

  def test_find
    @bank.save

    Bank.find(@bank.id).should == @bank
    Bank.find([@bank.id]).should == [@bank]
  end

  def test_find_all
    @bank.save

    Bank.find(:all).should include @bank
  end

  def test_find_first
    @bank.save
    Bank.find(:first).should == @bank
  end

  def test_find_last
    @bank.save

    Bank.find(:last).should == @bank
  end

  def test_find_all_with_conditions
    @bank.save

    # These two statements are equivalent
    Bank.find(:all, :conditions => {:name => "Wells Fargo"}).should include @bank
    Bank.find(:all, :conditions => {:name => ["==","Wells Fargo"]}).should include @bank
    
    Bank.find(:all, :conditions => {:name => ["!=","Chase"]}).should include @bank
    Bank.find(:all, :conditions => {:name => ["!=","Wells Fargo"]}).should_not include @bank
  end

  def test_find_multiple
    @bank.save
    @bank2 = Bank.new(:name => "Citi")
    @bank2.save

    all_banks = Bank.find(:all)
    all_banks.should include @bank
    all_banks.should include @bank2
  end

  def test_find_ordering
    @bank.save
    @bank2 = Bank.new(:name => "Citi")
    sleep(1)
    @bank2.save

    all_banks = Bank.find(:all, :order => :numdesc)
    all_banks[1].should == @bank
    all_banks[0].should == @bank2    
  end

  def test_find_between
    @bank.code = 8
    @bank.save

    Bank.find(:all, :conditions => {:code => 5..9}).should include @bank
    Bank.find(:all, :conditions => {:code => ["><", "5 9"]}).should include @bank
 
    Bank.find(:all, :conditions => {:code => ["<>", 5..9]}).should_not include @bank
    Bank.find(:all, :conditions => {:code => ["<>", "5 9"]}).should_not include @bank
  end

  def test_find_equal_number
    @bank.code = 8
    @bank.save

    Bank.find(:all, :conditions => {:code => ["==", 8]}).should include @bank   
  end
end
