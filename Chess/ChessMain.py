# MAIN DRIVER

import pygame as p
import ChessEngine

p.init()

width = height = 512
dimension = 8
square_size = height // dimension
max_fps = 15
images = {}


# INITIALIZING IMAGES
def loadImages():
    pieces = ["wP", "wN", "wB", "wQ", "wK", "wR", "bP", "bR", "bQ", "bK", "bB", "bN"]
    for piece in pieces:
        images[piece] = p.transform.scale(p.image.load(piece + ".png"), (square_size - 1, square_size - 1))


# USER INPUT AND GRAPHICAL UPDATES
def main():
    screen = p.display.set_mode((width, height))
    clock = p.time.Clock()
    screen.fill(p.Color("white"))
    gs = ChessEngine.GameState()  # GAME STATE FROM CHESS ENGINE
    loadImages()
    running = True

    while running:
        for e in p.event.get():
            if e.type == p.quit:
                running = False
        drawGameState(screen, gs)
        clock.tick(max_fps)
        p.display.flip()


# DRAWS GRAPHICS
def drawGameState(screen, gs):
    drawBoard(screen)
    drawPieces(screen, gs.board)


# DRAWS SQUARES
def drawBoard(screen):
    colors = [p.Color("white"), p.Color("gray")]
    for r in range(dimension):
        for c in range(dimension):
            color = colors[((r + c) % 2)]
            p.draw.rect(screen, color, p.Rect(c * square_size, r * square_size, square_size, square_size))


# DRAWS PIECES ON THE BOARD
def drawPieces(screen, board):
    for r in range(dimension):
        for c in range(dimension):
            piece = board[r][c]
            if piece != "--":
                screen.blit(images[piece], p.Rect(c * square_size, r * square_size, square_size - 1, square_size - 1))


# FOR CALLING MAIN
if __name__ == "__main__":
    main()
