WIDTH= 960
HEIGTH= 540

function love.load()

    math.randomseed(os.time())
    love.window.setMode(WIDTH,HEIGTH)--,{resizable = true,minwidth = 854, minheight = 480})
    love.window.setTitle("Ping Pong")
    racket1= {}
    racket1.x = 10
    racket1.y = HEIGTH/2 - 40
    racket1.w= 20
    racket1.h= 80
    racket1.speed = 0 --velocidade de deslocamento da raquete 1
    racket1.score= 0

    racket2= {}
    racket2.w= 20
    racket2.h= 80
    racket2.x = WIDTH - 10 - racket2.w
    racket2.y = HEIGTH/2 - 40
    racket2.speed = 0
    racket2.score= 0

    ball= {}
    ball.x = WIDTH/2
    ball.y = HEIGTH/2
    ball.w = 20
    ball.h = 20
    ball.dx = 0 -- velocidade da bola no eixo x
    ball.dy = 0
    ball.service_direction = 1 --a bola se move para direita

    bigFont = love.graphics.newFont('Thirteen-Pixel-Fonts.ttf',70)
    smallFont = love.graphics.newFont('Thirteen-Pixel-Fonts.ttf',30)

    state= 'start'

    sound = {}
    sound.hit_racket = love.audio.newSource("Hit_hurt 5.wav", 'static')
    sound.point= love.audio.newSource("Pickup_coin 1.wav", 'static')
    sound.hit_screen = love.audio.newSource("Blip_select 3.wav", 'static')

end

function love.update(dt)
    ------Colisao bola c/ raquete 1
    --Muda direção ao colidir
    if collides(ball, racket1) then 
        ball.dx = -ball.dx * 1.09
        ball.x = racket1.x + racket1.w
        ball.dy = math.random(-200,200)
        sound.hit_racket:play()
    end
    ------Colisao bola c/ raquete 2
    if collides(ball, racket2) then 
        ball.dx = -ball.dx * 1.09
        ball.x = racket2.x - ball.w
        ball.dy = math.random(-200,200)
        sound.hit_racket:play()
    end

    --Colisão borda superior
    if ball.y < 0 then
        ball.y = 0
        ball.dy= -ball.dy
        sound.hit_racket:play()
    end
    --Colisão borda a direita
    if ball.x + ball.w > WIDTH then 

        centralizes(ball)
        sound.point:play()
        racket1.score = racket1.score + 1 --ponto player 1
        if racket1.score == 3 then
            state= 'start'
        else
            ball.service_direction = -1
            state = 'serve'
        end

    end

     --Colisão borda a esquerda
    if ball.x < 0 then 
        sound.point:play()
        centralizes(ball)
        racket2.score = racket2.score + 1 --ponto player 2
        if racket2.score == 3 then
            state = 'start'
        else
            ball.service_direction = 1
            state = 'serve'
        end


    end

    --Colisão borda inferior
    if ball.y + ball.h > HEIGTH then
        sound.hit_racket:play()
        ball.y = HEIGTH - ball.h
        ball.dy = -ball.dy
    end

    
    ball.x = ball.x + ball.dx * dt --movimenta bola eixo x
    ball.y = ball.y + ball.dy * dt --movimenta bola eixo y

    --n deixa raquete sair da tela
    confinesracket(racket1)
    confinesracket(racket2)

    --velocidade raquetes
    racket1.y = racket1.y + racket1.speed * dt
    racket2.y = racket2.y + racket2.speed * dt

    --Movimentação da racket 1
    if love.keyboard.isDown('w')then
        racket1.speed = - 300
    elseif love.keyboard.isDown('s') then
        racket1.speed = 300
    else
        racket1.speed = 0
    end
    --Movimentação da racket 2
    --if love.keyboard.isDown('up')then
    --    racket2.speed = - 300
    --elseif love.keyboard.isDown('down') then
    --    racket2.speed = 300
    --else
    --    racket2.speed = 0
    --end

    --      Move a raquete 2 avaliando a posição no eixo y da bolla, e se acrescentando atravez do atributo speed da raquete ate se iguale
    -- 2)ATIVIDADE 2 ->
    if state == 'play'  then
        if ball.y > racket2.y + racket2.h or ball.y + ball.h < racket2.y  then
           racket2.speed = -320
        elseif ball.y < racket2.y then
            racket2.speed =  320
        else
            racket2.speed= 0
        end

    end
    -- ------------------------------------------------------ OBS (assim a maquina ja pode errar conforme a dificuldade aumenta)

end

function love.draw()
    love.graphics.setColor(1, 20/255, 1)
    love.graphics.setFont(smallFont)

    --Estado inicial
    if state == 'start' then
        love.graphics.printf('Pressione Enter para jogar!', 0, HEIGTH/4, WIDTH, 'center')
    elseif state == 'serve' then
        love.graphics.printf('Pressione Espaço para servir!', 0, HEIGTH/4, WIDTH, 'center')
    end
    
    --Pontuação
    love.graphics.setFont(bigFont)
    love.graphics.printf(racket1.score, 200, HEIGTH/2, WIDTH, 'left')
    love.graphics.printf(racket2.score, 0, HEIGTH/2, WIDTH-200, 'right')

    --Deseja bola e raquete apos pressionadoa enter

    love.graphics.setColor(20/255, 1, 1)
    love.graphics.rectangle('line', racket1.x, racket1.y,racket1.w,racket1.h)
    love.graphics.rectangle('line', racket2.x, racket2.y,racket2.w,racket2.h)

    love.graphics.rectangle('line', ball.x, ball.y,ball.w,ball.h)


end

function collides(ball,racket)
    --Bola acima ou abaixo da raquete com uma lacuna entre os dois
    if ball.y > racket.y + racket.h or ball.y + ball.h < racket.y then
        return false
    end
    --Bola do lado direito ou esquerdo da raquete com lacuna entre eles
    if ball.x > racket.x + racket.w or ball.x + ball.w < racket.x then
        return false
    end
    return true
end

--callback
function love.keypressed(key)
    if state == 'start' and key == 'return' then
        ball.dx = ball.service_direction * 500
        ball.dy = math.random(-150.150)
        state= 'play'
        racket1.score = 0
        racket2.score = 0
        racket2.y = HEIGTH/2 - 40 -- Coloca a raquete 2(da maquina) no centro
    end
    
    if state == 'serve' and key == 'space' then
        ball.dx = ball.service_direction * 500
        ball.dy = math.random(-150.150)
        state= 'play'
        racket2.y = HEIGTH/2 - 40 -- Coloca a raquete 2(da maquina) no centro
    end
end

function confinesracket(racket)
    if racket.y < 0 then
        racket.y=0
    end
    if racket.y + racket.h > HEIGTH then
        racket.y = HEIGTH - racket.h
    end

end


function centralizes(ball)
    ball.x = WIDTH/2
    ball.y = HEIGTH/2
    ball.dx = 0
    ball.dy = 0
end

