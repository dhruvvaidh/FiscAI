locals {
  transaction_categories = jsondecode(
    file("${path.module}/transaction_categories.json")
  )
}

# Intent definition for querying spending by category
resource "aws_lexv2models_intent" "get_spending_by_category" {
  name        = "GetSpendingByCategory"
  description = "Retrieve the total amount spent in a specified category over a given time period."
  bot_id      = aws_lexv2models_bot.finance_assistant.id
  bot_version = aws_lexv2models_bot_locale.english_locale.bot_version
  locale_id   = aws_lexv2models_bot_locale.english_locale.locale_id

  # Sample utterances
  sample_utterance { utterance = "How much did I spend on {Category} last month" }
  sample_utterance { utterance = "Show me my {Category} expenses for {TimePeriod}" }
  sample_utterance { utterance = "What did I spend on {Category} in {TimePeriod}" }
  sample_utterance { utterance = "Give me my {Category} spending for {TimePeriod}" }
  sample_utterance { utterance = "My spending on {Category} {TimePeriod}" }
  sample_utterance { utterance = "I spent how much on {Category} {TimePeriod}?" }

  fulfillment_code_hook {
    enabled = true
  }

  slot {
    name            = "Category"
    slot_type_id    = aws_lexv2models_slot_type.category.slot_type_id
    slot_constraint = "Required"

    value_elicitation_setting {
      prompt_specification {
        message_groups {
          message {
            plain_text_message {
              value = "Which category?"
            }
          }
        }
        max_retries     = 2
        allow_interrupt = true
      }
      prompt_selection_strategy = "Random"
    }
  }

  slot {
    name            = "TimePeriod"
    slot_type_id    = "AMAZON.Date"
    slot_constraint = "Required"

    value_elicitation_setting {
      prompt_specification {
        message_groups {
          message {
            plain_text_message {
              value = "For which period?"
            }
          }
        }
        max_retries     = 2
        allow_interrupt = true
      }
      prompt_selection_strategy = "Random"
    }
  }

  closing_setting {
    active = true
    closing_response {
      message_group {
        message {
          plain_text_message {
            value = "Is there anything else you'd like to know about your spending?"
          }
        }
      }
      allow_interrupt = true
    }
  }

  depends_on = [
    aws_lexv2models_slot_type.category,
    aws_lexv2models_bot_locale.english_locale
  ]
}
# Category slot
resource "aws_lexv2models_slot" "category_slot" {
  name         = "Category"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  intent_id    = aws_lexv2models_intent.get_spending_by_category.intent_id
  slot_type_id = aws_lexv2models_slot_type.category.slot_type_id
  value_elicitation_setting {
    slot_constraint = "Required"
    
    prompt_specification {
      max_retries = 2  # This should match the number of retry specifications
      allow_interrupt = true
      
      message_group {
        message {
          plain_text_message {
            value = "Which spending category would you like to know about? For example: groceries, dining, entertainment, etc."
          }
        }
      }

      message_selection_strategy = "Random"

      # Initial prompt
      prompt_attempts_specification {
        map_block_key = "Initial"
        allow_interrupt = true

        allowed_input_types {
          allow_audio_input = true
          allow_dtmf_input  = true
        }

        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000
          audio_specification {
            max_length_ms  = 15000
            end_timeout_ms = 640
          }
          dtmf_specification {
            max_length         = 20
            end_timeout_ms     = 5000
            deletion_character = "*"
            end_character      = "#"
          }
        }

        text_input_specification {
          start_timeout_ms = 30000
        }
      }

      # First retry
      prompt_attempts_specification {
        map_block_key = "Retry1"
        allow_interrupt = true

        allowed_input_types {
          allow_audio_input = true
          allow_dtmf_input  = true
        }

        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000
          audio_specification {
            max_length_ms  = 15000
            end_timeout_ms = 640
          }
          dtmf_specification {
            max_length         = 20
            end_timeout_ms     = 5000
            deletion_character = "*"
            end_character      = "#"
          }
        }

        text_input_specification {
          start_timeout_ms = 30000
        }
      }

      # Second retry - Add this block
      prompt_attempts_specification {
        map_block_key = "Retry2"
        allow_interrupt = true

        allowed_input_types {
          allow_audio_input = true
          allow_dtmf_input  = true
        }

        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000
          audio_specification {
            max_length_ms  = 15000
            end_timeout_ms = 640
          }
          dtmf_specification {
            max_length         = 20
            end_timeout_ms     = 5000
            deletion_character = "*"
            end_character      = "#"
          }
        }

        text_input_specification {
          start_timeout_ms = 30000
        }
      }
    }
  }
}

# Time frame slot
resource "aws_lexv2models_slot" "time_period_slot" {
  name         = "TimePeriod"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  intent_id    = aws_lexv2models_intent.get_spending_by_category.intent_id
  slot_type_id = "AMAZON.Date"

  value_elicitation_setting {
    slot_constraint = "Required"

    prompt_specification {
  max_retries     = 2
  allow_interrupt = true
  message_selection_strategy = "Random"

  message_group {
    message {
      plain_text_message {
        value = "For what time frame would you like to view your spending? (e.g., last week, this month)"
      }
    }
  }

  # Initial Attempt
  prompt_attempts_specification {
    map_block_key = "Initial"
    allow_interrupt = true

    allowed_input_types {
      allow_audio_input = true
      allow_dtmf_input  = true
    }

    text_input_specification {
      start_timeout_ms = 30000
    }

    audio_and_dtmf_input_specification {
      start_timeout_ms = 4000

      audio_specification {
        max_length_ms  = 15000
        end_timeout_ms = 640
      }

      dtmf_specification {
        max_length         = 513
        end_timeout_ms     = 5000
        deletion_character = "*"
        end_character      = "#"
      }
    }
  }

  # Retry 1
  prompt_attempts_specification {
    map_block_key = "Retry1"
    allow_interrupt = true

    allowed_input_types {
      allow_audio_input = true
      allow_dtmf_input  = true
    }

    text_input_specification {
      start_timeout_ms = 30000
    }

    audio_and_dtmf_input_specification {
      start_timeout_ms = 4000

      audio_specification {
        max_length_ms  = 15000
        end_timeout_ms = 640
      }

      dtmf_specification {
        max_length         = 513
        end_timeout_ms     = 5000
        deletion_character = "*"
        end_character      = "#"
      }
    }
  }

  # Retry 2
  prompt_attempts_specification {
    map_block_key = "Retry2"
    allow_interrupt = true

    allowed_input_types {
      allow_audio_input = true
      allow_dtmf_input  = true
    }

    text_input_specification {
      start_timeout_ms = 30000
    }

    audio_and_dtmf_input_specification {
      start_timeout_ms = 4000

      audio_specification {
        max_length_ms  = 15000
        end_timeout_ms = 640
      }

      dtmf_specification {
        max_length         = 513
        end_timeout_ms     = 5000
        deletion_character = "*"
        end_character      = "#"
      }
    }
  }
}

  }
}


# Category slot type
resource "aws_lexv2models_slot_type" "category" {
  name        = "Category"
  description = "Custom slot type for transaction categories"
  bot_id      = aws_lexv2models_bot.finance_assistant.id
  bot_version = "DRAFT"
  locale_id   = "en_US"

  value_selection_setting { resolution_strategy = "TopResolution" }

  dynamic "slot_type_values" {
    for_each = local.transaction_categories
    content {
      sample_value { value = slot_type_values.value.sampleValue.value }
      synonyms       = slot_type_values.value.synonyms
    }
  }

  depends_on = [
    aws_lexv2models_bot_locale.english_locale
  ]
}


# The null resource to fix the slot priority circular dependency
resource "null_resource" "update_get_spending_by_category_slot_priorities" {
  triggers = {
    bot_id    = aws_lexv2models_bot.finance_assistant.id
    locale_id = "en_US"
    intent_id  = aws_lexv2models_intent.get_spending_by_category.intent_id
  }

  provisioner "local-exec" {
    command = <<EOT
      set -xe

      BOT_ID=${self.triggers.bot_id}
      LOCALE=${self.triggers.locale_id}
      INTENT_NAME="GetSpendingByCategory"

      echo "🔍 Looking up intent ID for: $INTENT_NAME"
      INTENT_ID=$(aws lexv2-models list-intents \
        --bot-id $BOT_ID \
        --bot-version DRAFT \
        --locale-id $LOCALE \
        --query "intentSummaries[?intentName=='$INTENT_NAME'].intentId" \
        --output text)

      if [[ -z "$INTENT_ID" ]]; then
        echo "❌ Intent '$INTENT_NAME' not found. Exiting."
        exit 1
      fi

      echo "🔍 Looking up slot IDs..."
      SLOT_ID_CATEGORY=$(aws lexv2-models list-slots \
        --bot-id $BOT_ID \
        --bot-version DRAFT \
        --locale-id $LOCALE \
        --intent-id $INTENT_ID \
        --query "slotSummaries[?slotName=='Category'].slotId" \
        --output text)

      SLOT_ID_TIMEPERIOD=$(aws lexv2-models list-slots \
        --bot-id $BOT_ID \
        --bot-version DRAFT \
        --locale-id $LOCALE \
        --intent-id $INTENT_ID \
        --query "slotSummaries[?slotName=='TimePeriod'].slotId" \
        --output text)

      if [[ -z "$SLOT_ID_CATEGORY" || -z "$SLOT_ID_TIMEPERIOD" ]]; then
        echo "❌ One or both slot IDs not found. Exiting."
        exit 1
      fi

      echo "✅ Slot IDs: Category=$SLOT_ID_CATEGORY, TimeFrame=$SLOT_ID_TIMEPERIOD"

      echo "📄 Fetching intent definition..."
      aws lexv2-models describe-intent \
        --bot-id $BOT_ID \
        --bot-version DRAFT \
        --locale-id $LOCALE \
        --intent-id $INTENT_ID | \
        jq 'del(.creationDateTime, .lastUpdatedDateTime, .version, .name)' > intent_config.json

      echo "🛠️ Injecting slot priorities..."
      jq --arg cat "$SLOT_ID_CATEGORY" --arg tp "$SLOT_ID_TIMEPERIOD" \
        '.slotPriorities = [{"priority": 1, "slotId": $cat}, {"priority": 2, "slotId": $tp}]' \
        intent_config.json > updated_intent.json

      echo "🚀 Updating Lex intent..."
      aws lexv2-models update-intent \
        --bot-id $BOT_ID \
        --bot-version DRAFT \
        --locale-id $LOCALE \
        --intent-id $INTENT_ID \
        --cli-input-json file://updated_intent.json

      echo "✅ Slot priorities successfully updated for '$INTENT_NAME'"
    EOT
  }

  depends_on = [ 
    aws_lexv2models_intent.get_spending_by_category,
    aws_lexv2models_slot.category_slot,
    aws_lexv2models_slot.time_period_slot
  ]
}
