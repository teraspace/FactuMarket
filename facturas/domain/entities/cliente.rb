module Facturas
  module Domain
    module Entities
      class Cliente
        # Entidad de dominio Cliente que encapsula la identidad y atributos básicos del titular.

        attr_reader :id, :nombre

        def initialize(id:, nombre:)
          @id = id
          @nombre = nombre

          validate!
        end

        private

        def validate!
          raise ArgumentError, 'id de cliente requerido' if id.nil? || id.to_s.strip.empty?
          raise ArgumentError, 'nombre de cliente requerido' if nombre.nil? || nombre.to_s.strip.empty?
        end
      end
    end
  end
end
