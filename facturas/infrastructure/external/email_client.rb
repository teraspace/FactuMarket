require 'securerandom'
require 'json'
require_relative 'email_gateway'

module Facturas
  module Infrastructure
    module External
      class EmailClient < EmailGateway
        # Implementación simulada que emula el envío de facturas por correo electrónico.

        def enviar_factura(email, factura_pdf)
          puts "[INFO] Enviando factura a #{email} ..."
          puts "[OK] Factura enviada a #{email}"

          { status: 'ok', message_id: SecureRandom.uuid }
        end
      end
    end
  end
end
