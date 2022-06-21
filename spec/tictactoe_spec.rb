require './tictactoe'

describe Game do

  describe '#game_loop' do
    subject(:game_looping) { described_class.new }
    let(:player1_loop) { Player.new('Player 1') }
    let(:player2_loop) { Player.new('Player 2') }

    before do
      allow(game_looping).to receive(:puts)
      allow(game_looping).to receive(:draw_move)
      allow(game_looping).to receive(:process_turn)
      allow(game_looping).to receive(:game_over)
      allow(player1_loop).to receive(:moves) { [] }
      allow(player2_loop).to receive(:moves) { [] }
      allow(player1_loop).to receive(:make_move)
      allow(player2_loop).to receive(:make_move)
    end

    context 'when turn counter is 10' do
      before do
        allow(game_looping).to receive(:turn).and_return(10)
      end

      it 'calls #game_over' do
        expect(game_looping).to receive(:game_over)
        game_looping.game_loop(player1_loop, player2_loop)
      end
    end

    context 'when nobody wins' do
      before do
        allow(player1_loop).to receive(:winner?) { false }
        allow(player2_loop).to receive(:winner?) { false }
      end

      it 'calls #process_turn 9 times' do
        expect(game_looping).to receive(:process_turn).exactly(9).times
        game_looping.game_loop(player1_loop, player2_loop)
      end

      it 'calls game_over' do
        expect(game_looping).to receive(:game_over)
        game_looping.game_loop(player1_loop, player2_loop)
      end
    end

    context 'when player 1 wins ASAP' do
      before do
        allow(player1_loop).to receive(:winner?).and_return(false, false, true)
        allow(player2_loop).to receive(:winner?) { false }
      end

      it 'calls #process_turn 5 times' do
        expect(game_looping).to receive(:process_turn).exactly(5).times
        game_looping.game_loop(player1_loop, player2_loop)
      end

      it 'calls game_over' do
        expect(game_looping).to receive(:game_over)
        game_looping.game_loop(player1_loop, player2_loop)
      end
    end

    context 'when player 2 wins ASAP' do
      before do
        allow(player1_loop).to receive(:winner?).and_return(false)
        allow(player2_loop).to receive(:winner?).and_return(false, false, true)
      end

      it 'calls #process_turn 6 times' do
        expect(game_looping).to receive(:process_turn).exactly(6).times
        game_looping.game_loop(player1_loop, player2_loop)
      end

      it 'calls game_over' do
        expect(game_looping).to receive(:game_over)
        game_looping.game_loop(player1_loop, player2_loop)
      end
    end

    context 'when player 2 wins on the last turn' do
      before do
        allow(player1_loop).to receive(:winner?).and_return(false)
        allow(player2_loop).to receive(:winner?).and_return(false, false, false, true)
      end

      it 'calls #process_turn 8 times' do
        expect(game_looping).to receive(:process_turn).exactly(8).times
        game_looping.game_loop(player1_loop, player2_loop)
      end

      it 'calls game_over' do
        expect(game_looping).to receive(:game_over)
        game_looping.game_loop(player1_loop, player2_loop)
      end
    end
  end

  describe '#process_turn' do
    subject(:game_process) { described_class.new }
    let(:player1_process) { Player.new('Player 1') }
    let(:player2_process) { Player.new('Player 2') }

    before do
      allow(game_process).to receive(:draw_move)
      allow(game_process).to receive(:puts)
      allow(player1_process).to receive(:make_move)
    end

    context 'when player picks [1, 3]' do
      before do
        allow(player1_process).to receive(:make_move).and_return([1, 3])
      end

      it 'calls #draw_move with active player and [1, 3]' do
        expect(game_process).to receive(:draw_move).with(player1_process, [1, 3])
        game_process.process_turn(player1_process, player2_process)
      end

      it 'calls active_player.moves.push with 6' do
        expect(player1_process.moves).to receive(:push).with(6)
        game_process.process_turn(player1_process, player2_process)
      end
    end
  end

  describe '#game_over' do
    subject(:game_end) { described_class.new }
    let(:player1_end) { Player.new('Player 1') }
    let(:player2_end) { Player.new('Player 2') }

    before do
      allow(game_end).to receive(:puts)
      allow(game_end).to receive(:reinitialize)
    end

    context 'when player 1 won' do
      it 'increments player 1 score by 1' do
        scores = game_end.instance_variable_get(:@scores)
        expect(scores[player1_end]).to eq(0)
        game_end.game_over(player1_end, player2_end)
        scores = game_end.instance_variable_get(:@scores)
        expect(scores[player1_end]).to eq(1)
      end

      it 'announces player 1 as the winner' do
        victory_message = 'Congratulations! Player 1 won!'
        expect(game_end).to receive(:puts).with(victory_message)
        game_end.game_over(player1_end, player2_end)
      end

      it 'calls #reinitialize' do
        expect(game_end).to receive(:reinitialize)
        game_end.game_over(player1_end, player2_end)
      end
    end

    context 'when it was a draw' do
      before do
        allow(game_end).to receive(:turn).and_return(10)
      end

      it 'announces that there was no winner' do
        draw_message = 'There was no winner by turn 9.'
        expect(game_end).to receive(:puts).with(draw_message)
        game_end.game_over(player1_end, player2_end)
      end

      it 'calls #reinitialize' do
        expect(game_end).to receive(:reinitialize)
        game_end.game_over(player1_end, player2_end)
      end
    end
  end

  describe '#reinitialize' do
    subject(:game_reinit) { described_class.new }

    before do
      allow(game_reinit).to receive(:clear_game)
      allow(game_reinit).to receive(:run_match)
      allow(game_reinit).to receive(:puts)
      allow(game_reinit).to receive(:gets).and_return('')
      allow(game_reinit).to receive(:sleep)
    end

    context 'when the player wants to play again' do
      before do
        allow(game_reinit).to receive(:gets).and_return('Y')
      end

      it 'calls #clear_game' do
        expect(game_reinit).to receive(:clear_game)
        game_reinit.reinitialize
      end

      it 'calls #run_match' do
        expect(game_reinit).to receive(:run_match)
        game_reinit.reinitialize
      end
    end

    context 'when the player does not want to play again' do
      it 'does not call #clear_game' do
        expect(game_reinit).not_to receive(:clear_game)
        game_reinit.reinitialize
      end

      it 'does not call #run_match' do
        expect(game_reinit).not_to receive(:run_match)
        game_reinit.reinitialize
      end
    end
  end

  describe '#run_match' do
    subject(:game_main) { described_class.new }

    before do
      allow(game_main).to receive(:puts)
      allow(game_main).to receive(:gets).and_return('Player 1', 'Player 2')
      allow(game_main).to receive(:draw_board)
      allow(game_main).to receive(:game_loop)
    end

    it 'creates 2 player objects' do
      game_main.run_match
      player1 = game_main.instance_variable_get(:@player1)
      player2 = game_main.instance_variable_get(:@player2)
      expect(player1).to be_a(Player)
      expect(player2).to be_a(Player)
    end

    it 'calls #draw_board' do
      expect(game_main).to receive(:draw_board)
      game_main.run_match
    end

    it 'calls #game_loop' do
      expect(game_main).to receive(:game_loop)
      game_main.run_match
    end
  end
end

describe Player do
  describe 'winner?' do
    subject(:player_check_won) { described_class.new('Player') }

    context 'when the player has a winning combination' do
      before do
        allow(player_check_won).to receive(:moves).and_return([6, 5, 4])
      end

      it 'returns true' do
        expect(player_check_won.winner?).to be(true)
      end
    end

    context 'when the player does not have a winning combination' do
      before do
        allow(player_check_won).to receive(:moves).and_return([5, 4])
      end

      it 'returns false' do
        expect(player_check_won.winner?).to be(false)
      end
    end
  end
end
