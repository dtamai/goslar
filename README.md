# Goslar
Homework

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
