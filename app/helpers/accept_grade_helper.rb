module AcceptGradeHelper
  def handle_pitoscript(submission, failures)
    compiler_tests, interpreter_tests, parser_tests, lexer_tests = 7, 8, 14, 6
    compiler_tests_passed, interpreter_tests_passed, parser_tests_passed, lexer_tests_passed = compiler_tests, interpreter_tests, parser_tests, lexer_tests
    failures.each do |failure|
      if failure.include? 'compiler'
        compiler_tests_passed -= 1
      elsif failure.include? 'interpreter'
        interpreter_tests_passed -= 1
      elsif failure.include? 'parser'
        parser_tests_passed -= 1
      elsif failure.include? 'lexer'
        lexer_tests_passed -= 1
      end
    end

    weighted_test_grade = 0.3 * (lexer_tests_passed.to_f / lexer_tests) + 0.4 * (parser_tests_passed.to_f  / parser_tests) + 0.2 * (interpreter_tests_passed.to_f  / interpreter_tests) + 0.1 * (compiler_tests_passed.to_f  / compiler_tests)

    submission.test_grade_override = (weighted_test_grade * 100).round(3)
  end
end
