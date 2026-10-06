# Desafio DevSecOps — Gerenciador de Tarefas

## Sobre o Projeto
Este repositório faz parte do desafio prático do módulo de DevSecOps da ADA Tech.
Você receberá este projeto com vulnerabilidades propositais e uma pipeline incompleta.
Seu objetivo é **implementar a pipeline de segurança** e **corrigir as vulnerabilidades**.

## Estado atual
A pipeline está **incompleta**. Os steps de segurança precisam ser implementados por você.

## Sua missão
1. Implementar os steps de segurança no `pipeline.yml`
2. Fazer a pipeline **quebrar** ao detectar os problemas
3. Corrigir as vulnerabilidades encontradas
4. Fazer a pipeline **passar** com tudo verde ✅
5. Documentar o funcionamento da pipeline neste README

## O que implementar
- [ ] Secrets Scanning com **Gitleaks**
- [ ] SAST com **Semgrep**
- [ ] SCA com **Grype**
- [ ] Assinatura do artefato com cosign
- [ ] Deploy com **GitHub Pages**

## Como a pipeline funciona

> ### 1- Implantação Gitleaks

A abordagem escolhida para implementar o Gitleaks dentro da pipeline foi baixar o arquivo de instalação do programa na versão desejada utilizando o comando `wget -q`, descompactando o arquivo e movendo-o para a pasta `bin` do sistema em tempo de build — tornando está uma operação genérica para qualquer runner/operador. Após essa série de etapas, é executado o comando `gitleaks detect --verbose --redact` para realizar a detecção das *secrets*.
No decorrer da construção das demais atividades, houve a percepção de ajustar o código do Gitleaks para rodar via comando docker (`docker run --rm -v "${{ github.workspace }}:/path" zricethezav/gitleaks:latest detect --source="/path" -v`) o padronizando com as demais ferramentas.
O teste desta solução resultou em dois achados em commits passados. A tratativa adotada foi criar o arquivo `.gitleaksignore` contendo os *fingerprints* (hashes) destes commits, uma vez que a solução definitiva seria a revogação deste token e a geração de um novo que não estivesse exposto no código ou no histórico de commits.

### 2- Correção exposição de secrets

Para tratar as *secrets* expostas no código, as variáveis foram cadastradas no repositório do GitHub em **"Segredos e variáveis de ações"** (*Secrets and variables*). Para injetar essas informações de forma segura no ambiente sem expô-las via HTTP, o arquivo `.env` é gerado dinamicamente na pipeline utilizando o comando `sed` e as variáveis são importadas diretamente no arquivo `src/script.js`.

### 3- Implantação Semgrep

A solução escolhida para rodar o Semgrep foi utilizar sua imagem via Docker, evitando a necessidade de instalar a biblioteca no runner. Após a execução, o container é removido automaticamente, deixando o ambiente limpo. O comando utilizado foi (`docker run --rm -v "${{ github.workspace }}:/src" returntocorp/semgrep semgrep scan --config auto --config p/xss --error src/`).
Após a análise da pasta `src` pelo Semgrep, foi detetada uma vulnerabilidade no ficheiro `script.js` (linha 29), indicando o mau uso da função `eval()`, onde um utilizador mal-intencionado poderia realizar uma injeção de código. A correção adotada foi a remoção desta função, mantendo apenas o `console.log` para que o JavaScript interprete o `input.value` como texto puro.

### 4- Implantando SCA

A solução escolhida para rodar o Grype foi utilizar sua imagem via Docker pelo comando (`docker run --rm -v "${{ github.workspace }}:/project" -w /project anchore/grype:latest dir:. --fail-on medium`) seguindo o padrão usado nas demais implantações, sem a necessidade de instalar a ferramenta no runner e garantindo um ambiente isolado. Antes da execução do scanner, foi gerado o arquivo `package-lock.json` com o comando `npm install --package-lock-only` para mapear a árvore de dependências do projeto. Em seguida, a imagem do Grype foi executada para analisar a pasta raiz com a flag `--fail-on medium`, garantindo que o build seja interrompido caso sejam encontradas vulnerabilidades de severidade média ou superior. Após a varredura, o container é removido automaticamente, deixando o ambiente limpo.
Após a execução do Grype, foram detectadas vulnerabilidades de severidade Média, Alta e Crítica em dependências desatualizadas do projeto (`lodash`, `axios`, `express`, `body-parser` e `qs`). A tratativa adotada foi a execução do comando `npm audit fix` e `npm audit fix --force` para atualizar as bibliotecas para suas versões corrigidas, além do ajuste da versão do GitHub Actions no fluxo do workflow, o scanner executou com sucesso sem apontar vulnerabilidades.

### 5- Resultado

Todas as ferramentas de análise foram executadas de forma isolada e padronizada em containers Docker, interrompendo o build em caso de riscos e validando as correções aplicadas. O pipeline final do GitHub Actions encerrou sua execução com 100% de sucesso, garantindo um ambiente limpo, reprodutível e totalmente em conformidade com as regras de segurança estabelecidas.

### 6- Refatoração do código

Com auxílio de uma LLM fiz as seguintes correções no código do `index.html` e `script.js`:

* **Hardening no index.html:** A tag `<input>` foi atualizada com os atributos `maxlength` limitando a quantidade de caracteres, `autocomplete="off"` e `required`, restringindo entradas maliciosas e envios inválidos diretamente na interface pelo usuário.

* **Mitigação de XSS no script.js:** A função `addTask()` teve o uso de `innerHTML` substituído pela criação dinâmica de elementos com `textContent`, garantindo que qualquer texto digitado pelo usuário seja interpretado estritamente como dado puro.

* **Prevenção contra *Information Disclosure*:** O tratamento de erros no `fetch` deixou de exibir o rastreio do sistema `err.stack` em tela, exibindo apenas uma mensagem padrão para o usuário e mantendo os detalhes técnicos restritos aos logs do console.

* **Remoção de credenciais expostas:** As variáveis de senha do banco de dados (`DB_PASSWORD`) foram removidas do arquivo, impedindo a exposição de segredos no código do lado do cliente.

## URL de Produção
> [Link do GitHub Pages após o deploy](https://gsbarros17.github.io/projeto-devsecop-desafio/).
