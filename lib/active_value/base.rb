require "active_support/core_ext/hash/keys"

module ActiveValue
  # TODO: English Translation
  # ActiveRecordライクに定数を定義するための基底クラス
  # このクラスを継承したクラス内で宣言した定数をレコードとして扱うことができる。
  # 継承先のクラスでattr_accessorで要素を定義することで、その要素をDBのカラムのように扱うことができる。
  #
  # いくつかの要素名は予約されていて、定義があれば対応したメソッドが使用可能。
  #  要素名 : メソッド
  #  id : find
  #  symbol : define_question_methods
  #
  class Base

    # 未定義のメソッド呼び出しはall(Array)に委譲
    def self.method_missing(method, *args, &block)
      all.public_send(method, *args, &block)
    end

    # ActiveRecordライクに使えるfind, find_by, all, pluckを定義
    def self.find(index); find_by(id: index); end
    def self.find_by(conditions)
      all.find do |object|
        conditions.all? { |key, value| object.public_send(key) == value }
      end
    end
    def self.all
      constants.collect { |name| const_get(name) }.sort
    end
    def self.pluck(*accessors)
      map { |record| accessors.size > 1 ? Array(accessors).map { |accessor| record.public_send(accessor) } : record.public_send(accessors.first) }
    end

    # symbol要素の定義があれば、symbol名 + ? でインスタンスが同一のものか判別するメソッドを定義
    def self.define_question_methods(attr_name = :symbol)
      constants.collect { |name| const_get(name) }.each do |object|
        define_method(object.public_send(attr_name).to_s + '?') { self == object } if object.respond_to?(attr_name)
      end
    end

    # 定義したaccessorを順序を保ったまま保持したいためオーバーライド。従来のattr_accessorの挙動は変更しない。
    def self.attr_accessor(*several_variants)
      @accessors = *several_variants
      super
    end

    # accessor一覧を取得するメソッド
    def self.accessors
      readers = instance_methods.reject { |attr| attr.to_s[-1] == '=' }
      writers = instance_methods.select { |attr| attr.to_s[-1] == '=' }.map { |attr| attr.to_s.chop.to_sym }
      accessors = readers & writers - [:!]
      Array(@accessors) | accessors.reverse!
    end

    # ActiveRecordのnewのようにハッシュで初期化を行える機能と
    # コピーコンストラクタ(に似た何か)を定義(Shallowコピー)
    def initialize(attributes = {})
      case attributes
      when self.class then self.class.accessors.stringify_keys.each { |attribute| public_send(attribute + '=', attributes.public_send(attribute)) }
      when Hash       then attributes.stringify_keys.each { |key, value| public_send(key + '=', value) if respond_to?(key + '=') }
      end
    end

    # ActiveRecordと同様に要素へハッシュアクセスで取得できるようにアクセサを定義
    #def [](attribute);         public_send(attribute);                  end
    #def []=(attribute, value); public_send(attribute.to_s + '=', value) end

    # Hash型へ浅い変換を行う。値がコンテナ(Hash, Array)を含んでいた場合もその中の探索は行わずそのまま出力をする。
    def to_shallow_hash
      self.class.accessors.inject(Hash.new) { |hash, key| hash[key] = public_send(key); hash }.reject { |key, value| value.nil? }
    end

    # Hash型へ深い変換を行う。値がコンテナ(Hash, Array)を含んでいた場合、このクラスが含まれなくなるまで探索とHashへの変換を再帰的に行う。
    def to_deep_hash
      scan = ->(value) do
        case value
        when Hash           then value.inject(Hash.new) { |h, (k, v)| h[k] = scan.call(v); h }
        when Array          then value.map { |v| scan.call(v) }
        when ConstantRecord then scan.call(value.to_shallow_hash)
        else value
        end
      end
      self.class.accessors.inject(Hash.new) { |hash, key| hash[key] = scan.call(public_send(key)); hash }
    end
    alias_method :to_h, :to_deep_hash

    def to_json
      to_h.to_json
    end

    def inspect
      hash = to_shallow_hash
      Hash === hash ? '#<' << self.class.name.split('::').last << ' ' << hash.map { |key, value| key.to_s << ': ' << value.inspect }.join(', ') << '>' : hash.inspect
    end

    # Spaceship Operatorを定義、id等の比較可能な識別子が最初に定義されることが前提、存在しなければobject_idを参照する。
    # TODO: ソート順序の基準となるattrの宣言を行うメソッドの実装
    def <=>(another)
      attr = self.class.accessors.first || :object_id
      public_send(attr) <=> another.public_send(attr)
    end

  end
end