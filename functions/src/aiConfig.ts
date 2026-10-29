import { SchemaType } from "@google/generative-ai";
// Импортираме подготвената база от знания с правила от книгата
import knowledgeBase from "./knowledge_base.json";

/**
 * 1. Строг Grounding System Prompt (Zero Hallucination)
 * Принуждава AI да анализира текста САМО въз основа на предоставените правила.
 */
export const SYSTEM_INSTRUCTION = `
Ти си квалифициран коректор по български език за платформата Slovo AI.
Твоята ЕДИНСТВЕНА задача е да анализираш подадения от потребителя текст за грешки, като използваш САМО И ЕДИНСТВЕНО предоставената по-долу БАЗА ОТ ЗНАНИЯ (Knowledge Base) с правила от книгата "Как се пише?".

СТРИКТНИ ОГРАНИЧЕНИЯ (GROUNDING RULES):
1. Не използвай външни знания или общи езикови предположения, които не са описани в Базата от знания.
2. Ако дадена дума, фраза или пунктуационна конструкция не нарушава никое от правилата в Базата от знания, я считай за ПРАВИЛНА.
3. За всяка открита грешка трябва задължително да посочиш точното правило и обяснение, съответстващо на Базата от знания.
4. Маркирай is_typical_llm_error като true, ако грешката е типична за AI модели (напр. грешно членуване, английски кавички, буквални преводи).
5. Ако в текста НЯМА грешки според Базата от знания, върни has_errors: false, непроменения текст в corrected_text и празен масив errors: [].

БАЗА ОТ ЗНАНИЯ (KNOWLEDGE BASE):
${JSON.stringify(knowledgeBase, null, 2)}
`;

/**
 * 2. Деклариране на JSON Схема за структуриран отговор (Structured Output Schema)
 * Гарантира, че Gemini връща отговора СТРОГО според очаквания от Flutter формат.
 */
export const RESPONSE_SCHEMA = {
  type: SchemaType.OBJECT,
  properties: {
    has_errors: {
      type: SchemaType.BOOLEAN,
      description: "Дали в текста са открити грешки спрямо базата от знания",
    },
    original_text: {
      type: SchemaType.STRING,
      description: "Оригиналният текст, въведен от потребителя",
    },
    corrected_text: {
      type: SchemaType.STRING,
      description: "Пълният коригиран текст",
    },
    errors: {
      type: SchemaType.ARRAY,
      description: "Списък с всички открити грешки в текста",
      items: {
        type: SchemaType.OBJECT,
        properties: {
          original_phrase: { 
            type: SchemaType.STRING,
            description: "Оригиналната сбъркана фраза или дума"
          },
          correction: { 
            type: SchemaType.STRING,
            description: "Правилният вариант според книгата"
          },
          category: { 
            type: SchemaType.STRING,
            description: "Категория: Граматика, Правопис, Пунктуация, Слято/Разделно писане, Стилистика"
          },
          rule_explanation: { 
            type: SchemaType.STRING,
            description: "Подробно обяснение на правилото от базата от знания"
          },
          is_typical_llm_error: { 
            type: SchemaType.BOOLEAN,
            description: "Дали грешката е типична за AI езикови модели"
          },
        },
        required: [
          "original_phrase",
          "correction",
          "category",
          "rule_explanation",
          "is_typical_llm_error",
        ],
      },
    },
  },
  required: ["has_errors", "original_text", "corrected_text", "errors"],
};