module Facturas
  module Domain
    module Repositories
      class FacturaRepository
        # Contrato del dominio para la persistencia de facturas (capa Domain).

        def save(_factura)
          raise NotImplementedError, "#{self.class} debe implementar #save"
        end

        def find_by_id(_id)
          raise NotImplementedError, "#{self.class} debe implementar #find_by_id"
        end

        def all_by_date_range(_fecha_inicio, _fecha_fin)
          raise NotImplementedError, "#{self.class} debe implementar #all_by_date_range"
        end
      end
    end
  end
end
