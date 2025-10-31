module Facturas
  module Domain
    module Entities
      class Cliente
        # Entidad de dominio Cliente que encapsula la identidad y atributos básicos del titular.

        attr_reader :id, :nombre, :email

        def initialize(id:, nombre:, email:)
          @id = id
          @nombre = nombre
          @email = email

          validate!
        end

        private

        def validate!
          raise ArgumentError, 'id de cliente requerido' if id.nil? || id.to_s.strip.empty?
          raise ArgumentError, 'nombre de cliente requerido' if nombre.nil? || nombre.to_s.strip.empty?
          raise ArgumentError, 'email de cliente requerido' if email.nil? || email.to_s.strip.empty?
        end
      end
    end
  end
end
