# coding: utf-8
module RubyDanfe
  class CceGenerator
    def initialize(xml_nfe, xml_cce, logo = nil)
      @xml = xml_nfe
      @xml_cce = xml_cce
      @logo = logo
      @pdf = Document.new
      @vol = 0
    end

    def generatePDF
      render_titulo
      render_nfe
      render_carta_correcao
      render_emitente
      render_destinatario_remetente
      render_condicoes
      render_correcao
      @pdf
    end

    private

    def render_titulo
      @pdf.image @logo, { at: [37, 776], fit: [ 50, 50 ] } if @logo.present?
      @pdf.ibox 2.4, 20, 0.5, 1
      @pdf.ibox 1, 20, 0.5, 1.2, '', "CARTA DE CORREÇÃO ELETRÔNICA", {:size => 13, :align => :center, :border => 0, :style => :bold}
      @pdf.ibox 1, 20, 0.5, 1.9, '', "Não possui valor fiscal. Simples representação do evento indicado abaixo.", {:size => 10, :align => :center, :border => 0}
      @pdf.ibox 1, 20, 0.5, 2.6, '', "CONSULTE A AUTENTICIDADE NO SITE DA SEFAZ AUTORIZADORA.", {:size => 10, :align => :center, :border => 0}
    end
    
    def render_nfe
      @pdf.ititle 0.42, 10.00, 0.5, 4, "NOTA FISCAL ELETRÔNICA"
      @pdf.ibox 0.85, 2, 0.5, 4.5, "MODELO", @xml['ide/mod']
      @pdf.ibox 0.85, 2, 2.5, 4.5, "SÉRIE", @xml['ide/serie']
      @pdf.ibox 0.85, 2, 4.5, 4.5, "NÚMERO", @xml['ide/nNF']
      @pdf.ibox 0.85, 3, 6.5, 4.5, "MÊS / ANO DA EMISSÃO", Helper.format_date(@xml['ide/dhEmi']).last(7)
      @pdf.ibox 1.7, 11, 9.5, 4.5
      @pdf.ibarcode 1, 8, 10.1, 5.8, @xml['chNFe']
      @pdf.ibox 0.85, 9, 0.5, 5.35, "CHAVE DE ACESSO", @xml['chNFe'].gsub(/\D/, '').gsub(/(\d)(?=(\d\d\d\d)+(?!\d))/, "\\1 ")
    end

    def render_carta_correcao
      @pdf.ititle 1, 10, 0.5, 6.75, "CARTA DE CORREÇÃO ELETRÔNICA"

      @pdf.ibox 0.85, 2, 0.5, 7.25, "ORGÃO", @xml_cce['evento/infEvento/cOrgao']
      @pdf.ibox 0.85, 12, 2.5, 7.25, "AMBIENTE", descricao_ambiente(@xml_cce['evento/infEvento/tpAmb'])
      @pdf.ibox 0.85, 6, 14.5, 7.25, "DATA / HORA DO EVENTO", Helper.format_datetime(@xml_cce['evento/infEvento/dhEvento'])
      
      @pdf.ibox 0.85, 3, 0.5, 8.10, "EVENTO", @xml_cce['evento/infEvento/tpEvento']
      @pdf.ibox 0.85, 9, 3.5, 8.10, "DESCRIÇÃO DO EVENTO", @xml_cce['evento/infEvento/detEvento/descEvento']
      @pdf.ibox 0.85, 4, 12.5, 8.10, "SEQUÊNCIA DO EVENTO", @xml_cce['evento/infEvento/nSeqEvento']
      @pdf.ibox 0.85, 4, 16.5, 8.10, "VERSÃO DO EVENTO", @xml_cce['evento/infEvento/verEvento']

      @pdf.ibox 0.85, 10, 0.5, 8.95, "STATUS", @xml_cce['retEvento/infEvento/cStat'] + " - " + @xml_cce['retEvento/infEvento/xMotivo']
      @pdf.ibox 0.85, 5, 10.5, 8.95, "PROTOCOLO", @xml_cce['retEvento/infEvento/nProt']
      @pdf.ibox 0.85, 5, 15.5, 8.95, "DATA / HORA DO REGISTRO", Helper.format_datetime(@xml_cce['retEvento/infEvento/dhRegEvento'])
    end

    def render_emitente
      @pdf.ititle 1, 10, 0.5, 10.35, "EMITENTE"

      @pdf.ibox 0.85, 14, 0.5, 10.85, "NOME / RAZÃO SOCIAL", @xml['emit/xNome']
      @pdf.ibox 0.85, 6, 14.5, 10.85, "CNPJ / CPF", @xml['emit/CNPJ'].present? ? @xml['emit/CNPJ'] : @xml['emit/CPF']

      @pdf.ibox 0.85, 12, 0.5, 11.7, "ENDEREÇO", @xml['enderEmit/xLgr'] + ", " + @xml['enderEmit/nro']
      @pdf.ibox 0.85, 5, 12.5, 11.7, "DISTRITO / BAIRRO", @xml['enderEmit/xBairro']
      @pdf.ibox 0.85, 3, 17.5, 11.7, "CEP", @xml['enderEmit/CEP']

      @pdf.ibox 0.85, 10, 0.5, 12.55, "MUNICÍPIO", @xml['enderEmit/xMun']
      @pdf.ibox 0.85, 4, 10.5, 12.55, "FONE / FAX", @xml['enderEmit/fone']
      @pdf.ibox 0.85, 2, 14.5, 12.55, "UF", @xml['enderEmit/UF']
      @pdf.ibox 0.85, 4, 16.5, 12.55, "INSCRIÇÃO ESTADUAL", @xml['emit/IE']
    end

    def render_destinatario_remetente
      @pdf.ititle 1, 10, 0.5, 13.95, "DESTINATÁRIO / REMETENTE"

      @pdf.ibox 0.85, 14, 0.5, 14.45, "NOME / RAZÃO SOCIAL", @xml['dest/xNome']
      @pdf.ibox 0.85, 6, 14.5, 14.45, "CNPJ / CPF", @xml['dest/CNPJ'].present? ? @xml['dest/CNPJ'] : @xml['dest/CPF']

      @pdf.ibox 0.85, 12, 0.5, 15.3, "ENDEREÇO", @xml['enderDest/xLgr'] + ", " + @xml['enderDest/nro']
      @pdf.ibox 0.85, 5, 12.5, 15.3, "DISTRITO / BAIRRO", @xml['enderDest/xBairro']
      @pdf.ibox 0.85, 3, 17.5, 15.3, "CEP", @xml['enderDest/CEP']

      @pdf.ibox 0.85, 10, 0.5, 16.15, "MUNICÍPIO", @xml['enderDest/xMun']
      @pdf.ibox 0.85, 4, 10.5, 16.15, "FONE / FAX", @xml['enderDest/fone']
      @pdf.ibox 0.85, 2, 14.5, 16.15, "UF", @xml['enderDest/UF']
      @pdf.ibox 0.85, 4, 16.5, 16.15, "INSCRIÇÃO ESTADUAL", @xml['dest/IE']
    end

    def render_condicoes
      @pdf.ititle 1, 10, 0.5, 17.55, "CONDIÇÕES DE USO"
      @pdf.ibox 3.5, 20, 0.5, 18.05, "", ""
      @pdf.ibox 3.5, 19.5, 1, 18.4, "", @xml_cce['detEvento/xCondUso'].sub("I -", "\nI -").sub("II -", "\nII -").sub("III -", "\nIII -"), border: 0
    end

    def render_correcao
      @pdf.ititle 1, 10, 0.5, 22.1, "CORREÇÃO"
      @pdf.ibox 2, 20, 0.5, 22.6, "", ""
      @pdf.ibox 2, 19.5, 1, 22.95, "", @xml_cce['detEvento/xCorrecao'], border: 0
    end

    def descricao_ambiente(ambiente)
      case ambiente
      when '1'
        'PRODUÇÃO'
      when '2'
        'HOMOLOGAÇÃO'
      else
        ''
      end
    end

  end
end
