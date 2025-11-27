import middy from "@middy/core";
import httpErrorHandler from "@middy/http-error-handler";
import { APIGatewayEvent, APIGatewayProxyResult } from "aws-lambda";
import { schemaMiddleware } from "../middleware/schema.middleware";
import { shorLinkSchema } from "../schema/link.schema";
import { generateCode } from "../utils/generic.functions";
import { DynamoService, LINK_CODE_GROUP } from "../databases/dynamodb";

const SHORT_URL_PART = 'https://miweb.com';
type LinkDataForDb = {
    uuid: string,
    linkCode: string,
    fullUrl: string,
    shortUrl: string,
    code: string,
    created: string,
}

const shortenLinkLambda = async (
    event: APIGatewayEvent
): Promise<APIGatewayProxyResult> => {

    const body = JSON.parse(event.body || "{}");

    const fullLink = body.link;

    let code = generateCode();
    let exists = await new DynamoService().get(code);

    while (exists !== null) {
        console.log(`CODE:: ${code} EXITS FOR SOME URL`);
        code = generateCode();
        exists = await new DynamoService().get(code);
    }


    const item: LinkDataForDb = {
        uuid: `${LINK_CODE_GROUP}-${code}`,
        linkCode: LINK_CODE_GROUP,
        fullUrl: fullLink,
        shortUrl: `${SHORT_URL_PART}/${code}`,
        code: code,
        created: new Date().toISOString(),
    };

    const resp = await new DynamoService().save(item);

    console.log("Dynamo response...", resp);

    return {
        statusCode: 200,
        body: JSON.stringify({
            success: true,
            data: item
        }),
        headers: {
            "Content-type": "application/json",
        }
    };
}

export const handler = middy<APIGatewayEvent, APIGatewayProxyResult>(
    shortenLinkLambda
)
    .use(httpErrorHandler())
    .use(schemaMiddleware(shorLinkSchema))
