import ballerina/os;
import ballerinax/ai;
import ballerinax/googleapis.calendar;
import ballerinax/googleapis.gmail;

@ai:AgentTool
@display {
    label: "Read Emails",
    iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.gmail_4.0.1.png"
}
isolated function readEmails() returns gmail:Message[]|error {
    gmail:ListMessagesResponse messageList = check gmailClient->/users/me/messages(q = "label:INBOX is:unread");
    gmail:Message[] messages = messageList.messages ?: [];
    gmail:Message[] completeMessages = [];
    foreach gmail:Message message in messages {
        gmail:Message completeMsg = check gmailClient->/users/me/messages/[message.id](format = "full");
        completeMessages.push(completeMsg);
    }
    return completeMessages;
}

@ai:AgentTool
@display {
    label: "Send Email",
    iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.gmail_4.0.1.png"
}
isolated function sendEmail(string[] to, string subject, string body) returns gmail:Message|error {
    gmail:MessageRequest requestMessage = {to, subject, bodyInText: body};
    gmail:Message message = check gmailClient->/users/me/messages/send.post(requestMessage);
    return gmailClient->/users/me/messages/[message.id]/modify.post({removeLabelIds: ["UNREAD"]}); // Mark as read
}

@ai:AgentTool
@display {
    label: "Get Calander Events",
    iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.calendar_3.2.1.png"
}
isolated function getCalanderEvents() returns stream<calendar:Event, error?>|error {
    return calendarClient->getEvents(userEmail);
}

@ai:AgentTool
@display {
    label: "Create Calander Event",
    iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.calendar_3.2.1.png"
}
isolated function createCalanderEvent(calendar:InputEvent event) returns calendar:Event|error {
    return calendarClient->createEvent(userEmail, event);
}

final ai:AzureOpenAiProvider _personalAiAssistantModel = check new (serviceUrl, apiKey, deploymentId, apiVersion);
final ai:Agent _personalAiAssistantAgent = check new (
    systemPrompt = {
        role: "Personal AI Assistant",
        instructions: string `You are Nova, an intelligent personal AI assistant designed to help '${userName}' stay organized and efficient.
Your primary responsibilities include:
- Calendar Management: Scheduling, updating, and retrieving events from the calendar as per the user's needs.
- Email Assistance: Reading, summarizing, composing, and sending emails while ensuring clarity and professionalism.
- Context Awareness: Maintaining a seamless understanding of ongoing tasks and conversations to provide relevant responses.
- Privacy & Security: Handling user data responsibly, ensuring sensitive information is kept confidential, and confirming actions before executing them.
Guidelines:
- Respond in a natural, friendly, and professional tone.
- Always confirm before making changes to the user's calendar or sending emails.
- Provide concise summaries when retrieving information unless the user requests details.
- Prioritize clarity, efficiency, and user convenience in all tasks.`
    }, model = _personalAiAssistantModel, tools = [readEmails, sendEmail, getCalanderEvents, createCalanderEvent]
);
