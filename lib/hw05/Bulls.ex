defmodule Bulls.Game do
    def check_if_number(n) do
        if is_number(n) do
            %{}
        else
            %{
                guess: n
            }
        end
    end

    def check_for_bulls_cows(st, guess) do
        b = 0
        c = 0
        {b,c} = check_loop(b, c, 0, st, guess)
        {b,c}
    end
    
    def check_loop(b, c, counter, st, guess) do
        if counter == 4 do
            {b,c}
        else
            secretDigit = Enum.at(st.secretCode, counter)
            index = get_index(secretDigit, Enum.with_index(String.graphemes(guess)))
            b = if secretDigit == elem(Integer.parse(Enum.at(String.graphemes(guess), counter)), 0) do
                b + 1
            else    
                b
            end
            c = if index >= 0 and index != counter do
                c + 1
            else    
                c
            end
            check_loop(b, c, counter + 1, st, guess)
        end
    end
    
    def get_index(target, l) do
        if l == [] do
            -1
        else
            [head | tail] = l
            if is_number(elem(head, 0)) do
                if elem(head, 0) == target do
                    elem(head, 1)
                 else
                    get_index(target, tail)
                end
            else
                if elem(Integer.parse(elem(head, 0)), 0) == target do
                    elem(head, 1)
                 else
                    get_index(target, tail)
                end
            end
        end
    end

    def guess_code(st, guess) do
        invalidG = if (String.length(guess) != 4) or (not check_if_unique(guess)) do
            true
        else    
            false
        end
        
        if invalidG do
            %{
                invalidGuess: true,
                won: false,
                history: st.history,
                guesses: st.guesses,
                secretCode: st.secretCode
            }
        else
            {b,c} = check_for_bulls_cows(st, guess)
            w = if b == 4 do
                true
            else
                false
            end
            
            currHistory = st.history
            currHistory = currHistory ++ [%{guess: guess, bulls: b, cows: c}]
            currGuesses = st.guesses
            currGuesses = currGuesses + 1
            newGuess = ""
            IO.inspect st
            %{
                invalidGuess: invalidG,
                won: w,
                history: currHistory,
                guesses: currGuesses,
                secretCode: st.secretCode,
                totalPlayers: st.totalPlayers,
                totalReadies: st.totalReadies,
                playersReady: st.playersReady,
                gameName: st.gameName
            }
        end
    end
    
    def check_if_unique(n) do
        set = Enum.uniq(String.graphemes(n))
        if length(set) == String.length(n) do
            true
        else
            false
        end
    end
    
    def create_secret_code(arr) do
        if length(arr) == 4 do
            arr
        else
            r = Enum.random(0..9)
            arr = if get_index(r, Enum.with_index(arr)) == -1 do
                arr ++ [r]
            else
                arr
            end
            create_secret_code(arr)
        end
    end

    def begin(name) do
        %{
            secretCode: create_secret_code([]),
            history: [],
            guesses: 0,
            invalidGuess: false,
            won: false,
            totalPlayers: 0,
            totalReadies: 0,
            playersReady: false,
            gameName: name
        }
    end

    def view(st, name, type) do
        IO.inspect st.secretCode
        %{
            history: st.history,
            guesses: st.guesses,
            invalidGuess: st.invalidGuess,
            won: st.won,
            name: name,
            totalPlayers: st.totalPlayers,
            totalReadies: st.totalReadies,
            playersReady: st.playersReady,
            playerType: type,
            gameName: st.gameName
        }
    end

    def set_player_type(st, type) do
        tp = if type == "player" do
            st.totalPlayers + 1
        else
            st.totalPlayers - 1
        end

        %{
            history: st.history,
            guesses: st.guesses,
            invalidGuess: st.invalidGuess,
            won: st.won,
            secretCode: st.secretCode,
            totalPlayers: tp,
            totalReadies: st.totalReadies,
            playersReady: st.playersReady,
            gameName: st.gameName
        }
    end

    def set_ready(st, ready) do
        tr = if ready do
            st.totalReadies + 1
        else
            st.totalReadies - 1
        end

        pr = if (st.totalPlayers > 0) and (tr == st.totalPlayers) do
            true
        else
            false
        end

        %{
            history: st.history,
            guesses: st.guesses,
            invalidGuess: st.invalidGuess,
            won: st.won,
            secretCode: st.secretCode,
            totalPlayers: st.totalPlayers,
            totalReadies: tr,
            playersReady: pr,
            gameName: st.gameName
        }
    end
end