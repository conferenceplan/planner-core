module ExcludedItemsSurveyMapsHelper
  def GetSurveyAnswerExcludedItems
        answerType = AnswerType.find_by_name("ItemConflict")
        surveyAnswers = SurveyAnswer.find :all,  :conditions => ['answertype_id = ?', answerType.id]
        return surveyAnswers
  end
end
