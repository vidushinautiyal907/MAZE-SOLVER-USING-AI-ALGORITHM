import tkinter as tk
from queue import Queue
import time

# Maze configuration
maze = [
    [0, 1, 0, 0, 0, 0],
    [0, 1, 0, 1, 1, 0],
    [0, 0, 0, 1, 0, 0],
    [1, 1, 0, 0, 0, 1],
    [0, 0, 0, 1, 0, 0]
]

rows, cols = len(maze), len(maze[0])
start = (0, 0)
end = (4, 5)

# GUI setup
cell_size = 60
root = tk.Tk()
root.title("Maze Solver (BFS)")
canvas = tk.Canvas(root, width=cols*cell_size, height=rows*cell_size)
canvas.pack()

# Draw maze grid
def draw_maze():
    for i in range(rows):
        for j in range(cols):
            color = "white"
            if maze[i][j] == 1:
                color = "black"
            canvas.create_rectangle(
                j*cell_size, i*cell_size,
                (j+1)*cell_size, (i+1)*cell_size,
                fill=color, outline="gray"
            )

# Highlight path
def mark_cell(i, j, color):
    canvas.create_rectangle(
        j*cell_size, i*cell_size,
        (j+1)*cell_size, (i+1)*cell_size,
        fill=color, outline="gray"
    )
    root.update()
    time.sleep(0.2)

# BFS Algorithm
def bfs():
    queue = Queue()
    queue.put(start)
    visited = set([start])
    parent = {start: None}

    while not queue.empty():
        x, y = queue.get()
        mark_cell(x, y, "lightblue")

        if (x, y) == end:
            mark_path(parent)
            return

        for dx, dy in [(-1,0),(1,0),(0,-1),(0,1)]:
            nx, ny = x+dx, y+dy
            if 0 <= nx < rows and 0 <= ny < cols and maze[nx][ny] == 0 and (nx, ny) not in visited:
                visited.add((nx, ny))
                parent[(nx, ny)] = (x, y)
                queue.put((nx, ny))

    print("No path found!")

# Mark the final path
def mark_path(parent):
    node = end
    while node:
        mark_cell(node[0], node[1], "green")
        node = parent[node]

# Run
draw_maze()
canvas.create_text(60, 10, text="Solving...", anchor="nw")
root.after(1000, bfs)
root.mainloop()
