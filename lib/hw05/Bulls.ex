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

    def guess_code(st, guess, playerName) do
        invalidG = ((String.length(guess) != 4) or (not check_if_unique(guess))) and (guess !== "pass")

        # Assume all entries are valid
        if invalidG do
            %{
                invalidGuess: true,
                won: false,
                history: st.history,
                guesses: st.guesses,
                secretCode: st.secretCode,
                totalPlayers: st.totalPlayers,
                totalReadies: st.totalReadies,
                playersReady: st.playersReady,
                gameName: st.gameName
            }
        else
            {b,c} = if guess == "pass" do
                {0,0}
            else
                check_for_bulls_cows(st, guess)
            end
            
            #{b,c} = check_for_bulls_cows(st, guess)
            #w = if b == 4 do
            #    true
            #else
            #    st.won
            #end
            #w = b == 4 or st.won
            
            #currHistory = st.history
            #currHistory = currHistory ++ [%{guess: guess, bulls: b, cows: c}]
            
            
            currHistory = st.currRoundHistory
            currHistory = make_or_alter_guess(currHistory, guess, b, c, playerName, st.guesses)
            #currHistory = currHistory ++ [%{guess: guess, bulls: b, cows: c, user: playerName, roundNo: st.guesses}]
            # WHEN NAMES ARE WORKING, COMMENT OUT THE LINE ABOVE ME AND REPLACE WITH LINE ABOVE IT
           
            #currGuesses = st.guesses
            #currGuesses = currGuesses + 1
            newGuess = ""
            IO.inspect currHistory
            if length(currHistory) == st.totalPlayers do
                w = check_if_winner_exists(currHistory)
                newHistory = st.history
                newHistory = newHistory ++ currHistory
                if w do
                    pw = calculate_winners(currHistory)
                    #ul = updateWinsLosses(st.userList, pw)
                    {listOfPlayers,_acc} = Enum.map_reduce(currHistory, 0, fn x,acc -> {Map.get(x, :user),acc} end)
                    ul = updateWinsLosses(st.userList, pw, listOfPlayers)
                    %{
                        invalidGuess: false,
                        history: [],
                        guesses: 1,
                        secretCode: create_secret_code([]),
                        totalPlayers: 0,
                        totalReadies: 0,
                        playersReady: false,
                        gameName: st.gameName,
                        currRoundHistory: [],
                        userList: ul,
                        previousWinners: pw
                    }
                else
                    %{
                        invalidGuess: invalidG,
                        history: newHistory,
                        guesses: st.guesses + 1,
                        secretCode: st.secretCode,
                        totalPlayers: st.totalPlayers,
                        totalReadies: st.totalReadies,
                        playersReady: st.playersReady,
                        gameName: st.gameName,
                        currRoundHistory: [],
                        userList: st.userList,
                        previousWinners: st.previousWinners
                    }
                end
            else
                %{
                    invalidGuess: invalidG,
                    history: st.history,
                    guesses: st.guesses,
                    secretCode: st.secretCode,
                    totalPlayers: st.totalPlayers,
                    totalReadies: st.totalReadies,
                    playersReady: st.playersReady,
                    gameName: st.gameName,
                    currRoundHistory: currHistory,
                    userList: st.userList,
                    previousWinners: st.previousWinners
                }
            end
            #%{
            #    invalidGuess: invalidG,
            #    won: w,
            #    history: currHistory,
            #    guesses: currGuesses,
            #    secretCode: st.secretCode,
            #    totalPlayers: st.totalPlayers,
            #    totalReadies: st.totalReadies,
            #    playersReady: st.playersReady,
            #    gameName: st.gameName,
            #    currRoundHistory: st.currRoundHistory
            #}
        end
    end

    def check_if_winner_exists(hist) do
        if length(hist) == 0 do
            false
        else
            Map.get(hd(hist), :bulls) == 4 or check_if_winner_exists(tl(hist))
        end
    end

    def calculate_winners(hist) do
        if length(hist) == 0 do
            []
        else
            if Map.get(hd(hist), :bulls) == 4 do
                [Map.get(hd(hist), :user)] ++ calculate_winners(tl(hist))
            else
                calculate_winners(tl(hist))
            end
        end
    end

    def updateWinsLosses(arr, winners, listOfPlayers) do
        if length(arr) == 0 do
            []
        else
            if Enum.member?(winners, Map.get(hd(arr), :user)) do
                [%{user: Map.get(hd(arr), :user), wins: Map.get(hd(arr), :wins) + 1, losses: Map.get(hd(arr), :losses)}] ++ updateWinsLosses(tl(arr), winners, listOfPlayers)
            else
                if Enum.member?(listOfPlayers, Map.get(hd(arr), :user)) do
                    [%{user: Map.get(hd(arr), :user), wins: Map.get(hd(arr), :wins), losses: Map.get(hd(arr), :losses) + 1}] ++ updateWinsLosses(tl(arr), winners, listOfPlayers)
                else
                    [hd(arr)] ++ updateWinsLosses(tl(arr), winners, listOfPlayers)
                end
            end
        end
    end

    def make_or_alter_guess(arr, guess, b, c, user, roundNo) do
        if length(arr) == 0 do
            [%{guess: guess, bulls: b, cows: c, user: user, roundNo: roundNo}]
        else
            if Map.get(hd(arr), :user) == user do
                [%{guess: guess, bulls: b, cows: c, user: user, roundNo: roundNo}] ++ tl(arr)
            else
                [hd(arr)] ++ make_or_alter_guess(tl(arr), guess, b, c, user, roundNo)
            end
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
            guesses: 1,
            invalidGuess: false,
            totalPlayers: 0,
            totalReadies: 0,
            playersReady: false,
            gameName: name,
            currRoundHistory: [],
            userList: [],
            previousWinners: []
        }
    end

    def add_player(st, playerName) do
        if is_player_joined(st.userList, playerName) do
            st
        else
            ul = st.userList
            ul = ul ++ [%{user: playerName, wins: 0, losses: 0}]
            %{
                secretCode: st.secretCode,
                history: st.history,
                guesses: st.guesses,
                invalidGuess: st.invalidGuess,
                totalPlayers: st.totalPlayers,
                totalReadies: st.totalReadies,
                playersReady: st.playersReady,
                gameName: st.gameName,
                currRoundHistory: st.currRoundHistory,
                userList: ul,
                previousWinners: st.previousWinners
            }
        end
    end

    def is_player_joined(arr, playerName) do
        if length(arr) == 0 do
            false
        else
            if Map.get(hd(arr), :user) == playerName do
                true
            else
                is_player_joined(tl(arr), playerName)
            end
        end
    end

    def view(st, name, type) do
        IO.inspect st.secretCode
        %{
            history: st.history,
            guesses: st.guesses,
            invalidGuess: st.invalidGuess,
            name: name,
            totalPlayers: st.totalPlayers,
            totalReadies: st.totalReadies,
            playersReady: st.playersReady,
            playerType: type,
            gameName: st.gameName,
            userList: st.userList,
            previousWinners: st.previousWinners
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
            secretCode: st.secretCode,
            totalPlayers: tp,
            totalReadies: st.totalReadies,
            playersReady: st.playersReady,
            gameName: st.gameName,
            currRoundHistory: st.currRoundHistory,
            userList: st.userList,
            previousWinners: st.previousWinners
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
            secretCode: st.secretCode,
            totalPlayers: st.totalPlayers,
            totalReadies: tr,
            playersReady: pr,
            gameName: st.gameName,
            currRoundHistory: st.currRoundHistory,
            userList: st.userList,
            previousWinners: st.previousWinners
        }
    end
end