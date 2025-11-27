import Joi from "joi";

export const shorLinkSchema = Joi.object({
    link: Joi.string().email().required(),
})