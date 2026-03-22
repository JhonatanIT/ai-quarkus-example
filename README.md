# ai-quarkus-example

This project uses Quarkus, the Supersonic Subatomic Java Framework.

If you want to learn more about Quarkus, please visit its website: <https://quarkus.io/>.

## Running the application in dev mode

You can run your application in dev mode that enables live coding using:

```shell script
./mvnw quarkus:dev
```

> **_NOTE:_**  Quarkus now ships with a Dev UI, which is available in dev mode only at <http://localhost:8080/q/dev/>.

## Packaging and running the application

The application can be packaged using:

```shell script
./mvnw package
```

It produces the `quarkus-run.jar` file in the `target/quarkus-app/` directory.
Be aware that it’s not an _über-jar_ as the dependencies are copied into the `target/quarkus-app/lib/` directory.

The application is now runnable using `java -jar target/quarkus-app/quarkus-run.jar`.

If you want to build an _über-jar_, execute the following command:

```shell script
./mvnw package -Dquarkus.package.jar.type=uber-jar
```

The application, packaged as an _über-jar_, is now runnable using `java -jar target/*-runner.jar`.

## Creating a native executable

You can create a native executable using:

```shell script
./mvnw package -Dnative
```

Or, if you don't have GraalVM installed, you can run the native executable build in a container using:

```shell script
./mvnw package -Dnative -Dquarkus.native.container-build=true
```

You can then execute your native executable with: `./target/ai-quarkus-example-1.0.0-SNAPSHOT-runner`

If you want to learn more about building native executables, please consult <https://quarkus.io/guides/maven-tooling>.

## Related Guides

- LangChain4j OpenAI ([guide](https://docs.quarkiverse.io/quarkus-langchain4j/dev/index.html)): Provides the basic integration with LangChain4j
- LangChain4j Easy RAG ([guide](https://docs.quarkiverse.io/quarkus-langchain4j/dev/rag-easy-rag.html)): Provides the Easy RAG functionality with LangChain4j
- LangChain4j AI Gemini ([guide](https://docs.quarkiverse.io/quarkus-langchain4j/dev/index.html)): Provides integration of Quarkus LangChain4j with AI Gemini

## Provided Code

### LangChain4j Easy RAG

This code is a very basic sample service to start developing with Quarkus LangChain4j using Easy RAG.

This code is set up to use OpenAI as the LLM, thus you need to set the `QUARKUS_LANGCHAIN4J_OPENAI_API_KEY` environment variable to your OpenAI API key.

In `./easy-rag-catalog/` you can find a set of example documents that will be used to create the RAG index which the bot (`src/main/java/org/acme/Bot.java`) will ingest.

On first run, the bot will create the RAG index and store it in `easy-rag-catalog.json` file and reuse it on subsequent runs.
This can be disabled by setting the `quarkus.langchain4j.easy-rag.reuse-embeddings.enabled` property to `false`.

Add it to a Rest endpoint:
```java
    @Inject
    Bot bot;
    
    @POST
    @Produces(MediaType.TEXT_PLAIN)
    public String chat(String q) {
        return bot.chat(q);
    }
```

In a more complete example, you would have a web interface and use websockets that would provide more interactive experience, see [ChatBot Easy RAG Sample](https://github.com/quarkiverse/quarkus-langchain4j/tree/main/samples/chatbot-easy-rag) for such an example.

** Azure Deployment **

az login --tenant 0cc6383b-58a0-4562-9cea-32ea03e49f91
az group create --name quarkus-bot-rg-brazil --location brazilsouth
az storage account create --name jhonatanbotbr332 --resource-group quarkus-bot-rg-brazil --sku Standard_LRS --location brazilsouth
az functionapp create --resource-group quarkus-bot-rg-brazil --name ai-quarkus-bot-br --storage-account jhonatanbotbr332 --consumption-plan-location brazilsouth --os-type Linux --runtime java --runtime-version 21 --functions-version 4

Test
curl -X POST https://ai-quarkus-bot-br.azurewebsites.net/api/chat -H "Content-Type: text/plain" -d "Hello Bob, what is your name and what do you do?"

Fixes
az functionapp config appsettings set --name ai-quarkus-bot-br --resource-group quarkus-bot-rg-brazil --settings FUNCTIONS_WORKER_INIT_TIMEOUT=00:10:00
az functionapp config appsettings set --name ai-quarkus-bot-br --resource-group quarkus-bot-rg-brazil --settings "JAVA_OPTS=-XX:+TieredCompilation -XX:TieredStopAtLevel=1 -noverify"
