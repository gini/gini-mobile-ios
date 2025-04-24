#!/bin/bash
set -e

echo "Checking the last 3 commits for JIRA tickets..."
jira_ticket_pattern='[A-Z]+-[0-9]+'
jira_ticket=""

# Check latest commit
commit_message=$(git log -1 --pretty=%B)
jira_ticket=$(echo "$commit_message" | grep -oE "$jira_ticket_pattern" | head -1)

if [[ -n "$jira_ticket" ]]; then
  echo "JIRA Ticket Found in Last Commit: $jira_ticket"
else
  # Check second last commit
  commit_message=$(git log --no-merges -1 --pretty=%B)
  jira_ticket=$(echo "$commit_message" | grep -oE "$jira_ticket_pattern" | head -1)

  if [[ -n "$jira_ticket" ]]; then
    echo "JIRA Ticket Found in Second Last Commit: $jira_ticket"
  else    
    # Check third last commit
    commit_message=$(git log --no-merges -2 --pretty=%B)
    jira_ticket=$(echo "$commit_message" | grep -oE "$jira_ticket_pattern" | head -1)

    if [[ -n "$jira_ticket" ]]; then
      echo "JIRA Ticket Found in Third Last Commit: $jira_ticket"
    fi
  fi
fi

if [[ -n "$jira_ticket" ]]; then
  echo "::set-output name=ticket::${jira_ticket}"
  echo "JIRA_TICKET_NAME=${jira_ticket}" >> $GITHUB_OUTPUT
  echo "Found JIRA ticket: $jira_ticket"
else
  echo "No JIRA Ticket found in the last 3 commits. Build link will not be posted to Jira."
  echo "::set-output name=ticket::"
fi