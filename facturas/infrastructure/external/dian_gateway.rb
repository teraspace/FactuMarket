module Facturas
  module Infrastructure
    module External
      class DianGateway
        # Interfaz del gateway hacia la DIAN para enviar facturas electrónicas.

        def enviar_factura(_factura)
          raise NotImplementedError, "#{self.class} debe implementar #enviar_factura"
        end
      end
    end
  end
end
