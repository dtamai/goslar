# Goslar

[Goslar](https://en.wikipedia.org/wiki/Goslar) é uma cidade alemã que, durante a idade média, foi uma importante cidade do império romano e centro de mineração.

## Usando a API

Este guia assume que estão instalados Docker e docker-compose, também o Postman, o repositório foi clonado em uma pasta chamada _goslar_.

### Iniciando o projeto e dependências

Tudo pode ser executado pelo docker-compose, então basta executar

```
docker-compose up --build
```

para iniciar a aplicação e o banco de dados.

### Criando um cliente

Para fazer qualquer chamada na API você precisa um cliente, existe uma task de conveniência para isso:

```
docker exec -it goslar_app_1 rails customers:create
```

A task imprime um UUID (**customer_id**) para ser usado para identificação.

### Chamadas na API

Primeiro importe a coleção de chamadas _goslar_postman_collection.json_ no Postman. Existem três chamadas:

1. criação do pagamento via boleto
1. criação do pagamento via cartão de crédito
1. detalhes de um pagamento

Nas chamadas de criação basta colocar o **customer_id** no cabeçalho _Authorization_, no corpo da chamada já existe um JSON pré-preenchido válido, você pode modiicar os valores e ver como a API responde. Com cartão de crédito você pode colocar o número 9 como primeiro dígito do número do cartão para simular uma rejeição.

Na resposta de uma criação existe um cabeçalho _Location_ com a URI do pagamento para ver seus detalhes. Use essa URI na chamada de detalhes (ou apenas o UUID do final), e lembre de preencher o **customer_id** no cabeçalho.

### Executando os testes

Com o docker-compose ainda rodando:

```
docker exec -it goslar_app_1 rspec
```

## Design da solução

A API é implementada via Rails API + PostgreSQL como banco de dados, é uma API JSON via HTTP.

Como o desafio tem uma especificação bastante ampla e não define limites do que é avaliado, tentei fazer uma implementação mínima de diversos aspectos de uma aplicação, o princípio básico foi permitir postergar o máximo possível de decisões, isso significa limitar o impacto das decisões tomadas para deixar flexível o espaço para mudanças.

**Segurança**: os endpoints são autenticados e os acessos são limitados ao escopo de cliente autenticado, mas a autenticação em si consiste em passar o _customer_id_ no cabeçalho _Authorization_ da chamada. Isso pode ser facilmente trocado por uma baseada em JWT por exemplo, com mudanças necessárias em apenas uma classe; os testes vão quebrar porque essa parte de segurança não foi abstraída lá.

**Logs**: o log padrão do Rails é suficiente para operação normal então não implementei nada mais, além disso o padrão já é mandar os logs para o stdout da aplicação, então é fácil capturar os logs com algum agregador.

**Processamento do pagamento**: o processamento está síncrono e é uma das coisas mais difíceis de ser modificada, mesmo que a comunicação cliente-servidor não precise mudar - o cliente recebe uma URL para ver o estado do processamento quando quiser - é preciso cuidado no disparo da tarefa em background e controle de transações do banco de dados.

**Modelos anêmicos**: validação e lógica de negócio estão em classes específicas por uso, no desafio apenas a criação do pagamento. Isso permite variar bastante os usos dos modelos sem precisar espalhar mudanças no código.

**Apenas dois modelos**: não vi necessidade para criar mais modelos (Buyer, Card, etc,) já que não seriam usados para nada mas implicariam mais complexidade na implementação e também teria que tomar decisões sobre como lidar com vários casos.

**Payload de Payment**: o payload como JSONB foi apenas uma experiência com esse tipo de dados no banco, uma outra alternativa que considerei foi uma string criptografada para melhorar a segurança, escondendo os dados do cartão. Esses dados tem pouca utilidade no desafio, são recebidos, validados - apenas existência, outro ponto para extensão - e persistidos da forma mais conveniente para ser retornado quando solicitado.

**Testes**: os testes não cobrem muitos casos. Como dito no item acima, o payload tem pouca utilidade por isso não me preocupei em testá-lo. As classes de apoio das Operations também não tem teste porque seria um jeito de inibir modificações nessa parte, porém elas foram criadas para ser a parte volátil da interface entre Controller e Model. Modelos quase não tem teste porque quase não tem lógica.
