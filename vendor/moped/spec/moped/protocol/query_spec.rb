require "spec_helper"

describe Moped::Protocol::Query do

  describe "#clone" do

    let(:selector) do
      { active: true }
    end

    context "when there are fields in the query" do

      let(:options) do
        {
          request_id: 1000,
          flags: [ :tailable ],
          limit: 10,
          skip: 20,
          fields: { active: 1 },
          batch_size: 50
        }
      end

      let(:query) do
        described_class.new("moped_test", "users", selector, options)
      end

      let(:cloned) do
        query.clone
      end

      it "clones the selector" do
        expect(cloned.selector).not_to equal(query.selector)
      end

      it "clones the flags" do
        expect(cloned.flags).not_to equal(query.flags)
      end

      it "clones the fields" do
        expect(cloned.fields).not_to equal(query.fields)
      end
    end

    context "when there are no fields on the query" do

      let(:options) do
        {
          request_id: 1000,
          flags: [ :tailable ],
          limit: 10,
          skip: 20,
          batch_size: 50
        }
      end

      let(:query) do
        described_class.new("moped_test", "users", selector, options)
      end

      let(:cloned) do
        query.clone
      end

      it "clones the selector" do
        expect(cloned.selector).not_to equal(query.selector)
      end

      it "clones the flags" do
        expect(cloned.flags).not_to equal(query.flags)
      end

      it "does not clone the fields" do
        expect(cloned.fields).to be_nil
      end
    end
  end

  describe "#failure?" do

    let(:query) do
      described_class.new("moped", "people", { a: 1 })
    end

    let(:reply) do
      Moped::Protocol::Reply.new
    end

    context "when the reply is a query failure" do

      before do
        reply.flags = [ :query_failure ]
      end

      it "returns true" do
        expect(query).to be_failure(reply)
      end
    end

    context "when the reply is not a query failure" do

      before do
        reply.documents = [{}]
      end

      it "returns true" do
        expect(query).to_not be_failure(reply)
      end
    end
  end

  describe "#failure_exception" do

    let(:query) do
      described_class.new("moped", "people", { a: 1 })
    end

    let(:reply) do
      Moped::Protocol::Reply.new.tap do |message|
        message.documents = [{}]
      end
    end

    let(:exception) do
      query.failure_exception(reply)
    end

    it "returns a query failure" do
      expect(exception).to be_a(Moped::Errors::QueryFailure)
    end
  end

  describe ".fields" do

    it "matches the specification's field list" do
      expect(described_class.fields).to eq([
        :length, :request_id, :response_to, :op_code, :flags, :full_collection_name,
        :skip, :limit, :selector, :fields
      ])
    end
  end

  describe "#initialize" do

    let(:query) do
      described_class.new("moped", "people", { a: 1 })
    end

    it "sets the database" do
      expect(query.database).to eq("moped")
    end

    it "sets the collection" do
      expect(query.collection).to eq("people")
    end

    it "sets the full collection name" do
      expect(query.full_collection_name).to eq("moped.people")
    end

    it "sets the selector" do
      expect(query.selector).to eq({ a: 1 })
    end

    context "when flags are provided" do

      let(:query) do
        described_class.new("db", "coll", {}, flags: [ :slave_ok ])
      end

      it "sets the flags" do
        expect(query.flags).to eq([ :slave_ok ])
      end
    end

    context "when a request id option is provided" do

      let(:query) do
        described_class.new("db", "coll", {}, request_id: 10293)
      end

      it "sets the request id" do
        expect(query.request_id).to eq(10293)
      end
    end

    context "when a limit option is provided" do

      let(:query) do
        described_class.new("db", "coll", {}, limit: 5)
      end

      it "sets the limit" do
        expect(query.limit).to eq(5)
      end
    end

    context "when a skip option is provided" do

      let(:query) do
        described_class.new("db", "coll", {}, skip: 5)
      end

      it "sets the skip" do
        expect(query.skip).to eq(5)
      end
    end

    context "when a batch_size option is provided" do

      let(:query) do
        described_class.new("db", "coll", {}, batch_size: 5)
      end

      it "sets the batch_size" do
        expect(query.batch_size).to eq(5)
      end
    end

    context "when a fields option is provided" do

      let(:query) do
        described_class.new("db", "coll", {}, fields: { a: 1 })
      end

      it "sets the fields" do
        expect(query.fields).to eq({ a: 1})
      end
    end
  end

  describe "#op_code" do

    let(:query) do
      described_class.allocate
    end

    it "should eq 2004" do
      expect(query.op_code).to eq(2004)
    end
  end

  describe "#results" do

    let(:query) do
      described_class.new("moped", "people", { a: 1 })
    end

    let(:reply) do
      Moped::Protocol::Reply.new
    end

    it "returns the reply" do
      expect(query.results(reply)).to eq(reply)
    end
  end
end
