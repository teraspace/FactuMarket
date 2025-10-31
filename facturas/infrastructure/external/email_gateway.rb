module Facturas
  module Infrastructure
    module External
      class EmailGateway
        # Interfaz abstracta para el envío de facturas por correo electrónico.

        def enviar_factura(_email, _factura_pdf)
          raise NotImplementedError, "#{self.class} debe implementar #enviar_factura"
        end
      end
    end
  end
end
