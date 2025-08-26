# coding: utf-8
module RubyDanfe
  class DanfseGenerator
    def initialize(xml)
      @xml = xml
      @pdf = Document.new
      @vol = 0
    end

    attr_reader :municipios

    def municipios
      lib_path = File.expand_path("../../", __FILE__)
      @municipios ||= JSON.parse(File.read(File.join(lib_path, 'municipios.json')))
    end

    def generatePDF
      render_titulo
      render_prestador
      render_tomador
      render_intermediario
      render_discriminacao
      render_valor_total
      render_outras
      @pdf
    end

    private
    def render_titulo
      @pdf.ibox 2.55, 16.10, 0.25, 0.42, '',
        "PREFEITURA DO MUNICÍPIO DE #{municipios[@xml['infNFSe/cLocIncid']].upcase} \n" +
        "Secretaria Municipal da Fazenda \n" +
        "NOTA FISCAL ELETRÔNICA DE SERVIÇOS - NFS-e \n" +
        "RPS n° #{@xml['infNFSe/nNFSe']}, emitido em #{@xml['infNFSe/dhProc']}", {:align => :center, :valign => :center}

      @pdf.ibox 0.85, 4.47, 16.35, 0.42, "NÚMERO DA NOTA", "#{@xml['infNFSe/nNFSe'].rjust(8,'0')}"
      @pdf.ibox 0.85, 4.47, 16.35, 1.27, "DATA E HORA DE EMISSÃO", "#{@xml['infNFSe/dhProc'].gsub('T', ' ')}"
      @pdf.ibox 0.85, 4.47, 16.35, 2.12, "CÓDIGO DE VERIFICAÇÃO", @xml.attrib('infNFSe', 'Id')
    end

    def render_prestador
      @pdf.ibox 4.25, 20.57, 0.25, 2.97
      @pdf.ibox 0.85, 20.57, 0.25, 2.97, '', 'PRESTADOR DE SERVIÇOS', {border: 0, style: :bold, :align => :center, :valign => :center}
      @pdf.ibox 0.85, 20.57, 0.25, 3.82, "Nome/Razão Social", "#{@xml['emit/xNome']}", {border: 0}
      @pdf.ibox 0.85, 12,    0.25, 4.67, "CPF/CNPJ", "#{@xml['emit/CNPJ'] || @xml['emit/CPF']}", {border: 0}
      @pdf.ibox 0.85, 4.47,  12,   4.67, "Inscrição Municipal", "#{@xml['emit/enderNac/InscricaoMunicipal']}", {border: 0}
      @pdf.ibox 0.85, 20.57, 0.25, 5.52, "Endereço", "#{@xml['emit/enderNac/xLgr']} #{ @xml['emit/enderNac/nro'] } #{ @xml['emit/enderNac/xBairro'] }", {border: 0}
      @pdf.ibox 0.85, 10,    0.25, 6.37, "Município", "#{municipios[@xml['emit/enderNac/cMun']]}", {border: 0}
      @pdf.ibox 0.85, 4.47,  10,   6.37, "UF", "#{@xml['emit/enderNac/UF']}", {border: 0}
      @pdf.ibox 0.85, 4.47,  15,   6.37, "E-mail", "#{@xml['emit/email']}", {border: 0}
    end

    def render_tomador
      @pdf.ibox 4.25, 20.57, 0.25, 7.22
      @pdf.ibox 0.85, 20.57, 0.25, 7.22, '', 'TOMADOR DE SERVIÇOS', {border: 0, style: :bold, :align => :center, :valign => :center}
      @pdf.ibox 0.85, 20.57, 0.25, 8.07, "Nome/Razão Social", "#{@xml['DPS/infDPS/toma/xNome']}", {border: 0}
      @pdf.ibox 0.85, 12,    0.25, 8.92, "CPF/CNPJ", "#{@xml['DPS/infDPS/toma/CNPJ'] || @xml['DPS/infDPS/toma/CPF']}", {border: 0}
      @pdf.ibox 0.85, 4.47,  12,   8.92, "Inscrição Municipal", "#{@xml['DPS/infDPS/toma/InscricaoMunicipal']}", {border: 0}
      @pdf.ibox 0.85, 20.57, 0.25, 9.77, "Endereço", "#{@xml['DPS/infDPS/toma/end/endNac/xLgr']} #{ @xml['DPS/infDPS/toma/end/nro'] }", {border: 0}
      @pdf.ibox 0.85, 10,    0.25, 10.62, "Município", "#{municipios[@xml['DPS/infDPS/toma/end/endNac/cMun']]}", {border: 0}
      @pdf.ibox 0.85, 4.47,  10,   10.62, "UF", "#{@xml['DPS/infDPS/toma/end/endNac/UF']}", {border: 0}
      @pdf.ibox 0.85, 4.47,  15,   10.62, "E-mail", "#{@xml['DPS/infDPS/toma/email']}", {border: 0}
    end

    def render_intermediario
      @pdf.ibox 1.70, 20.57, 0.25,  11.47
      @pdf.ibox 0.85, 20.57, 0.25,  11.47, '', 'INTERMEDIÁRIO DE SERVIÇOS', {border: 0, style: :bold,:align => :center, :valign => :center}
      @pdf.ibox 0.85, 12,    0.25,  12.32, "Nome/Razão Social", "#{@xml['IdentificacaoIntermediarioServico/RazaoSocial']}", {border: 0}
      @pdf.ibox 0.85, 8,     12.25, 12.32, "CPF/CNPJ", "#{@xml['IdentificacaoIntermediarioServico/CpfCnpj/Cnpj'] || @xml['IdentificacaoIntermediarioServico/CpfCnpj/Cpf']}", {border: 0}
    end

    def render_discriminacao
      @pdf.ibox 9.35, 20.57, 0.25,  13.17
      @pdf.ibox 0.85, 20.57, 0.25,  13.17, '', 'DISCRIMINAÇÃO DOS SERVIÇOS', {border: 0, style: :bold,:align => :center, :valign => :center}
      @pdf.ibox 8, 19.57, 0.75,  14.02, "", "#{@xml['xDescServ']}", {border: 0}
    end

    def render_valor_total
      @pdf.ibox 1.70, 20.57, 0.25, 22.52
      @pdf.ibox 0.85, 20.57, 0.25, 22.52, '', "VALOR TOTAL DO SERVIÇO = R$#{Helper.numerify(@xml['valores/vServPrest/vServ'])}", { border: 0, style: :bold, align: :center, valign: :center }
      @pdf.inumeric 0.85, 4.06, 0.25, 23.37, "INSS",  ''
      @pdf.inumeric 0.85, 4.06, 4.31, 23.37, "IRRF",   ''
      @pdf.inumeric 0.85, 4.06, 8.37, 23.37, "CSLL",   ''
      @pdf.inumeric 0.85, 4.06, 12.43, 23.37, "COFINS", ''
      @pdf.inumeric 0.85, 4.32, 16.49, 23.37, "PIS/PASEP", ''
      @pdf.ibox     0.85, 20.57, 0.25, 24.22, "Código do Serviço", @xml['DPS/infDPS/serv/cServ/cTribNac']
      @pdf.inumeric 0.85, 3.46, 0.25, 25.07, "Valor Total das Deduções", ''
      @pdf.inumeric 0.85, 3.46, 3.71, 25.07, "Base de Cálculo",          ''
      @pdf.ibox     0.85, 3.46, 7.17, 25.07, "Alíquota",                 ''
      @pdf.inumeric 0.85, 3.46, 10.63, 25.07, "Valor do ISS",            ''
      @pdf.inumeric 0.85, 6.73, 14.09, 25.07, "Crédito",                 ''
      @pdf.ibox     0.85, 10.38, 0.25, 25.92, "Município da Prestação do Serviço", municipios[@xml['infNFSe/cLocIncid']], style: :bold
      @pdf.ibox     0.85, 10.19, 10.63, 25.92, "Número Inscrição da Obra", '', style: :bold
    end

    def render_outras
      @pdf.ibox 2.55, 20.57, 0.25,  26.77
      @pdf.ibox 0.85, 20.57, 0.25,  26.77, '', 'OUTRAS INFORMAÇÕES', {border: 0, style: :bold,:align => :center, :valign => :center}
      @pdf.ibox 1.70, 19.57, 0.75,  27.62, "", "#{@xml['InfNfse/OutrasInformacoes']}", {border: 0}
    end
  end
end
