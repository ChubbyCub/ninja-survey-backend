//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../base/SemaphoreCore.sol";
import "../base/SemaphoreGroups.sol";
import "../base/Ownable.sol";

contract Survey is SemaphoreCore, SemaphoreGroups, Ownable {
    // surveyQuestionsMap and surveyQuestions need to be kept in sync at all times.
    // map to accelerate look up.
    // Survey _question wrapper
    struct SurveyQuestionsWrapper {
        mapping(string => bool) surveyQuestionsMap;
        string[] surveyQuestions;
    }

    // name of this survey
    string public surveyName;

    // stores all response scores in a map
    mapping(string => uint[]) private questionToScoreList;
    uint private numRespondents;
    uint[] private surveyScores;
    SurveyQuestionsWrapper private surveyQuestionsWrapper;

    // control contract to update survey scores only when necessary
    bool private shouldUpdateSurveyScores;

    mapping(address => bool) private trackParticipationMap;

    constructor(
        string[] memory _surveyQuestions,
        address[] memory _participants,
        string memory _surveyName
    ) Ownable() {
        surveyQuestionsWrapper.surveyQuestions = _surveyQuestions;
        for (uint i = 0; i < _surveyQuestions.length; i++) {
            string memory question = _surveyQuestions[i];
            surveyQuestionsWrapper.surveyQuestionsMap[question] = true;
        }
        // a survey is a semaphore group.
        
        _createGroup(uint(keccak256(abi.encode(_surveyName))), 10, 0);
        surveyName = _surveyName;
        shouldUpdateSurveyScores = false;
    }
}