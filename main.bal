import ballerina/http;
import ballerinax/ai;

listener ai:Listener personalAiAssistantAgentListener = new (listenOn = check http:getDefaultListener());

service /personalAiAssistantAgent on personalAiAssistantAgentListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string agentResponse = check _personalAiAssistantAgent->run(request.message);
        return {message: agentResponse};
    }
}
