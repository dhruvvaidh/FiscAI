resource "aws_lexv2models_slot" "merchant_slot" {
  name         = "Merchant"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  intent_id    = aws_lexv2models_intent.transaction_search.intent_id
  slot_type_id = "AMAZON.AlphaNumeric"

  value_elicitation_setting {
    slot_constraint = "Required"

    prompt_specification {
      message_group {
        message {
          plain_text_message {
            value = "Which merchant would you like to search for?"
          }
        }
      }
      max_retries     = 2
      allow_interrupt = true
    }

    prompt_selection_setting {
      prompt_selection_strategy = "Random"
    }
  }

  depends_on = [
    aws_lexv2models_intent.transaction_search
  ]
}

resource "aws_lexv2models_slot" "min_amount_slot" {
  name         = "MinAmount"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  intent_id    = aws_lexv2models_intent.transaction_search.intent_id
  slot_type_id = "AMAZON.Number"

  value_elicitation_setting {
    slot_constraint = "Required"

    prompt_specification {
      message_group {
        message {
          plain_text_message {
            value = "What minimum amount should I use?"
          }
        }
      }
      max_retries     = 2
      allow_interrupt = true
    }

    prompt_selection_setting {
      prompt_selection_strategy = "Random"
    }
  }

  depends_on = [
    aws_lexv2models_intent.transaction_search
  ]
}

resource "aws_lexv2models_slot" "month_slot" {
  name         = "Month"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  intent_id    = aws_lexv2models_intent.monthly_summary.intent_id
  slot_type_id = "AMAZON.Date"

  value_elicitation_setting {
    slot_constraint = "Required"

    prompt_specification {
      message_group {
        message {
          plain_text_message {
            value = "Which month?"
          }
        }
      }
      max_retries     = 2
      allow_interrupt = true
    }

    prompt_selection_setting {
      prompt_selection_strategy = "Random"
    }
  }

  depends_on = [
    aws_lexv2models_intent.monthly_summary
  ]
}

resource "aws_lexv2models_slot" "year_slot" {
  name         = "Year"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  intent_id    = aws_lexv2models_intent.monthly_summary.intent_id
  slot_type_id = "AMAZON.Date"

  value_elicitation_setting {
    slot_constraint = "Required"

    prompt_specification {
      message_group {
        message {
          plain_text_message {
            value = "Which year?"
          }
        }
      }
      max_retries     = 2
      allow_interrupt = true
    }

    prompt_selection_setting {
      prompt_selection_strategy = "Random"
    }
  }

  depends_on = [
    aws_lexv2models_intent.monthly_summary
  ]
}
