using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

// spawn pieces and keep track of board state
public class Board : MonoBehaviour
{
    public GameObject[] pieces;
    public GameObject heldPiece;
    public GameObject heldShadow;
    public GameObject tetrominoesParent;
    public GameObject shadowParent;
    public static GameObject[] queue = new GameObject[7];
    public GameObject currentPiece;
    public GameObject currentShadow;
    public AudioSource blockPlacement;
    public AudioSource lineClear;

    private float landTimeCounter = 0f;
    private float fallTimeCounter = 0f;
    private float landTime = 1.2f;
    private float fallTime = 1f;
    private float softDropTime = 0.01f;
    private float DASTimeCounter = 0f;
    private float DASTime = 0.1f;
    private float ARRTimeCounter = 0f;
    private float ARRTime = 0f;

    // to keep track of spawning 7-bag in a cycle
    private static int height = 20;
    private static int width = 10;
    public static Transform[,] boardState = new Transform[height+1, width];
    private bool[] bagChoice = new bool[7];
    private int bagGenerateCounter = 0;
    private int bagSpawnCounter = 0;
    private int[] numberList = new int[7];
    public int linesCleared = 0;
    public static int score = 0;

    // Start is called before the first frame update
    void Start()
    {
        ResetBag();

        GenerateQueue(6);

        UpdateQueue();

        SpawnPiece();

        InitialiseBoardState();
    }


    // Update is called once per frame
    void Update()
    {
        // if the piece reaches the same position as shadow, considered landed
        if (currentPiece.transform.position == currentShadow.transform.position) {
            currentPiece.GetComponent<Tetrominoes>().landed = true;
        }
        else {
            currentPiece.GetComponent<Tetrominoes>().landed = false;
        }
        // if landed, if time exceeds fall time, hard drop
        if (currentPiece.GetComponent<Tetrominoes>().landed) {
            landTimeCounter += Time.deltaTime;

            if (landTimeCounter > landTime) {
                HardDrop();
            }
        }

        if (PressLeft()) {
            // piece will keep moving to left when left key is still being pressed and held
            Left();
        }

        if (HoldLeft()) {
            DASTimeCounter += Time.deltaTime;
            if (DASTimeCounter > DASTime) {
                ARRTimeCounter += Time.deltaTime;
                if (ARRTimeCounter > ARRTime) {
                    Left();
                    ARRTimeCounter = 0;
                }
            }            
        }
        
        if (PressRight()) {
            Right();
        }

        if (HoldRight()) {
            DASTimeCounter += Time.deltaTime;
            if (DASTimeCounter > DASTime) {
                ARRTimeCounter += Time.deltaTime;
                if (ARRTimeCounter > ARRTime) {
                    Right();
                    ARRTimeCounter = 0;
                }
            }
        }

        if (ReleaseHorizontal()) {
            DASTimeCounter = 0;
        }

        if (PressRotateCounterClockwise()) {
            RotateCounterClockwise();
        }

        if (PressRotateClockwise()) {
            RotateClockwise();
        }

        if (PressRotate180()) {
            Rotate180();
        }

        // piece will fall faster at soft drop time if down key is pressed, else piece will fall at normal fall time
        if (PressSoftDrop()) {
            GravityFall(softDropTime);
        }
        else {
            GravityFall(fallTime);
        }

        if (PressHardDrop()) {
            HardDrop();
        }

        if (PressHold()) {
            SwapHoldPiece();
        }

        List<int> clearedRows = CheckLineClear();
        ClearLine(clearedRows);
        ComputeScore();

        bool lose = CheckLose();
        if (lose) {
            SceneManager.LoadScene("GameOver");
        }

        UpdateShadow();
    }


    public bool MovedPiece() {
        if (PressLeft() || PressRight()) {return true;}
        return false;
    }


    public bool PressLeft() {
        if(Input.GetButtonDown("Horizontal") && (int)Input.GetAxisRaw("Horizontal") == -1) {return true;}
        return false;
    }


    public bool PressRight() {
        if(Input.GetButtonDown("Horizontal") && (int)Input.GetAxisRaw("Horizontal") == 1) {return true;}
        return false;
    }


    public bool HoldLeft() {
        if(Input.GetButton("Horizontal") && (int)Input.GetAxisRaw("Horizontal") == -1) {return true;}
        return false;
    }


    public bool HoldRight() {
        if(Input.GetButton("Horizontal") && (int)Input.GetAxisRaw("Horizontal") == 1) {return true;}
        return false;
    }


    public bool ReleaseHorizontal() {
        if((int)Input.GetAxisRaw("Horizontal") == 0) {return true;}
        return false;
    }


    public bool PressRotateCounterClockwise() {
        if (Input.GetButtonDown("RotateCounterClockwise")) {return true;}
        return false;
    }


    public bool PressRotateClockwise() {
        if (Input.GetButtonDown("RotateClockwise")) {return true;}
        return false;
    }


    public bool PressRotate180() {
        if (Input.GetButtonDown("Rotate180")) {return true;}
        return false;
    }


    public bool PressSoftDrop() {
        if (Input.GetButton("SoftDrop")) {return true;}
        return false;
    }


    public bool PressHardDrop() {
        if (Input.GetButtonDown("HardDrop")) {return true;}
        return false;
    }


    public bool PressHold() {
        if(Input.GetButtonDown("Hold")) {return true;}
        return false;
    }


    public void Left() {
        GameObject piece = currentPiece;
        GameObject shadow = currentShadow;
        piece.transform.position += Vector3.left;
        shadow.transform.position += Vector3.left;

        // if not valid move, return to original position
        bool valid = CheckValidMove(currentPiece);

        if (!valid) {
            piece.transform.position += Vector3.right;
            shadow.transform.position += Vector3.right;
        }
    }


    public void Right() {
        GameObject piece = currentPiece;
        GameObject shadow = currentShadow;
        piece.transform.position += Vector3.right;
        shadow.transform.position += Vector3.right;

        bool valid = CheckValidMove(currentPiece);

        if (!valid) {
            piece.transform.position += Vector3.left;
            shadow.transform.position += Vector3.left;
        }
    }


    public void RotateCounterClockwise() {
        GameObject piece = currentPiece;
        GameObject shadow = currentShadow;
        Vector3 rotationPoint = piece.GetComponent<Tetrominoes>().rotationPoint;

        piece.transform.RotateAround(piece.transform.TransformPoint(rotationPoint), Vector3.forward, 90);
        shadow.transform.RotateAround(shadow.transform.TransformPoint(rotationPoint), Vector3.forward, 90);

        bool valid = CheckValidMove(piece);

        if (!valid) {
            piece.transform.RotateAround(piece.transform.TransformPoint(rotationPoint), Vector3.forward, -90);
            shadow.transform.RotateAround(shadow.transform.TransformPoint(rotationPoint), Vector3.forward, -90);
        }
    }


    public void RotateClockwise() {
        GameObject piece = currentPiece;
        GameObject shadow = currentShadow;
        Vector3 rotationPoint = piece.GetComponent<Tetrominoes>().rotationPoint;

        piece.transform.RotateAround(piece.transform.TransformPoint(rotationPoint), Vector3.forward, -90);
        shadow.transform.RotateAround(shadow.transform.TransformPoint(rotationPoint), Vector3.forward, -90);

        bool valid = CheckValidMove(piece);

        if (!valid) {
            piece.transform.RotateAround(piece.transform.TransformPoint(rotationPoint), Vector3.forward, 90);
            shadow.transform.RotateAround(shadow.transform.TransformPoint(rotationPoint), Vector3.forward, 90);
        }
    }


    public void Rotate180() {
        GameObject piece = currentPiece;
        GameObject shadow = currentShadow;
        Vector3 rotationPoint = piece.GetComponent<Tetrominoes>().rotationPoint;

        piece.transform.RotateAround(piece.transform.TransformPoint(rotationPoint), Vector3.forward, 180);
        shadow.transform.RotateAround(shadow.transform.TransformPoint(rotationPoint), Vector3.forward, 180);

        bool valid = CheckValidMove(piece);

        if (!valid) {
            piece.transform.RotateAround(piece.transform.TransformPoint(rotationPoint), Vector3.forward, -180);
            shadow.transform.RotateAround(shadow.transform.TransformPoint(rotationPoint), Vector3.forward, -180);
        }
    }


    public void GravityFall(float time) {
        GameObject piece = currentPiece;   
        int y = Mathf.RoundToInt(piece.transform.position.y);
        fallTimeCounter += Time.deltaTime;

        if (fallTimeCounter > time && y > 0) {
            piece.transform.position += Vector3.down;

            bool valid = CheckValidMove(piece);

            
            if (!valid) {
                piece.transform.position += Vector3.up;
            }
            fallTimeCounter = 0;
        }
    }


    public void HardDrop() {
        GameObject piece = currentPiece;
        GameObject shadow = currentShadow;
        blockPlacement.Play();
        piece.transform.position = shadow.transform.position;
        piece.GetComponent<Tetrominoes>().landed = true;
        piece.GetComponent<Tetrominoes>().placed = true;
        Destroy(shadow);
        UpdateBoardState();
        UpdateQueue();
        SpawnPiece();
        landTimeCounter = 0;
    }

    public void ResetBag() {
        for (int i = 0; i < 7; i++){
            bagChoice[i] = false;
        }
        bagGenerateCounter = 0;
    }


    public void GenerateQueue(int n) {
        // generate the first n pieces to be viewed by player
        for (int i = 0; i < n; i++) {
            GeneratePiece();
        }
    }


    public void GeneratePiece() {
        // if finished generating from selection of bag, renew its status.
        if (bagGenerateCounter == 7) {
            ResetBag();
        } 

        // spawn random piece from the bag choice
        int rand_num;

        while (true) {
            rand_num = Random.Range(0, 7);
            if (!bagChoice[rand_num]) {
                bagChoice[rand_num] = true;
                bagGenerateCounter++;

                break;
            } 
        }

        // add to queue
        GameObject piece;
        piece = Instantiate(pieces[rand_num], new Vector3(0, 30, 0), Quaternion.identity);
        piece.transform.parent = tetrominoesParent.transform;
        numberList[bagGenerateCounter - 1] = rand_num;

        queue[bagGenerateCounter - 1] = piece;
    }


    public void UpdateQueue() {
        Vector3 queueLocation = new Vector3(14, 18, 0);
        int loopCounter = 7 - bagSpawnCounter;
        int counter = 0;

        if (bagSpawnCounter < 2) {
            for (int i = bagSpawnCounter + 1; i < bagSpawnCounter + 6; i++) {
                queue[i].transform.position = queueLocation + Vector3.down * 4 * counter;
                counter++;
            }
        }
        else {
            for (int i = bagSpawnCounter + 1; i < 7; i++) {
                queue[i].transform.position = queueLocation + Vector3.down * 4 * counter;
                counter++;
            }
            for (int i = 0; i < bagSpawnCounter - 1; i++) {
                queue[i].transform.position = queueLocation + Vector3.down * 4 * counter;
                counter++;
            }
        }
    }


    // public void UpdateQueue() {
    //     Vector3 queueLocation = new Vector3(14, 16, 0);
    //     for (int i = 1; i < 5; i++) {
    //         queue[i].transform.position = queueLocation + Vector3.down * 4 * (i - 1);
    //     }

    //     queue[5].transform.position = queueLocation + Vector3.down * 4 * 4;
    // }


    public void SpawnPiece() {
        if (currentPiece != null) {
            currentPiece.GetComponent<Tetrominoes>().isCurrentPiece = false;
        }
        // will spawn the pieces according to queue etc 0, 1, 2, 3...
        currentPiece = queue[bagSpawnCounter];
        currentPiece.transform.position = currentPiece.GetComponent<Tetrominoes>().spawnLocation;
        // StartCoroutine(WaitOneFrame());
        currentPiece.GetComponent<Tetrominoes>().isCurrentPiece = true;
        bagSpawnCounter++;

        // replace the spawned piece with new one at the index
        GeneratePiece();

        CreateShadow();

        if (bagSpawnCounter == 7) {
            bagSpawnCounter = 0;
        }
    }


    public bool CheckOutOfBound(GameObject piece) {
        foreach(Transform child in piece.transform) {
            int x = Mathf.RoundToInt(child.transform.position.x);
            int y = Mathf.RoundToInt(child.transform.position.y);

            if (x < 0 || x > 9 || y < 0){
                return true;
            }
        }
        return false;
    }


    public bool CheckValidMove(GameObject piece) {
        bool outofbound = CheckOutOfBound(piece);
        bool validity = true;

        if (!outofbound) {
            foreach (Transform child in piece.transform) {

                int x = Mathf.RoundToInt(child.transform.position.x);
                int y = Mathf.RoundToInt(child.transform.position.y);
                
                if (y < height+1) {
                    if (boardState[y, x] != null) {
                        validity = false;
                    }
                }
            }
        }
        return validity && !outofbound;    
    }


    public List<int> CheckLineClear() {
        List<int> clearedRows = new List<int>();
        bool fullRow = true;

        for (int i = 0; i < height; i++) {
            for (int j = 0; j < width; j++) {                    
                if (boardState[i, j] == null) {
                    fullRow = false;
                }
            }
            if (fullRow) {
                clearedRows.Add(i);
            }
            fullRow = true;
        }

        return clearedRows;
    }


    public void ClearLine(List<int> rows) {
        int lineCleared = 0;
        foreach (int row in rows) {
            for (int j = 0; j < width; j++) {
                Destroy(boardState[row - lineCleared, j].gameObject);
                boardState[row - lineCleared, j] = null;
            }

            for (int i = row-lineCleared; i < height -1; i++) {
                for (int j = 0; j < width; j++) {
                    if (boardState[i+1, j] != null) {
                        boardState[i, j] = boardState[i+1, j];
                        boardState[i, j].transform.position += Vector3.down;
                        boardState[i+1, j] = null;
                    }
                }
            }
            // temporary line cleared per piece placement
            lineCleared++;
            // cumulative lines cleared
            linesCleared++;
            lineClear.Play();
        }
    }


    public void ComputeScore() {
        score = linesCleared*100;
    }


    public void InitialiseBoardState() {
        for (int i = 0; i < height; i++) {
            for (int j = 0; j < width; j++) {                    
                boardState[i, j] = null;
            }
        }
    }
    

    public void UpdateBoardState() {
        for (int i = 0; i < height; i++) {
            for (int j = 0; j < width; j++) {
                foreach (Transform child in currentPiece.transform) {

                    int x = Mathf.RoundToInt(child.transform.position.x);
                    int y = Mathf.RoundToInt(child.transform.position.y);
                    
                    if (x < width && x >= 0 && y < height+1 && y >= 0) {
                        boardState[y, x] = child;
                    }
                }
            }
        }
    }


    public bool CheckLose() {
        for (int j = 0; j < width; j++) {                    
            if(boardState[height, j] != null){
                return true;
            }
        }
        return false;
    }


    public void SwapHoldPiece() {
        // swap the shadow
        if (heldShadow == null) {
            heldShadow = currentShadow;
            heldShadow.SetActive(false);
        }
        else {                
            GameObject temp = currentShadow;
            currentShadow = heldShadow;
            heldShadow = temp;

            int x = Mathf.RoundToInt(currentPiece.transform.position.x);

            currentShadow.transform.position = new Vector3(x, 20, 0);
            currentShadow.SetActive(true);
            currentShadow.GetComponent<Tetrominoes>().isCurrentPiece = true;
            heldShadow.SetActive(false);
            heldShadow.GetComponent<Tetrominoes>().isCurrentPiece = false;
            heldShadow.GetComponent<Tetrominoes>().inHold = true;
        }

        // swap the normal piece

        // check if hold has nothing yet, if none replace with current piece.
        if (heldPiece == null) {
            currentPiece.GetComponent<Tetrominoes>().isCurrentPiece = false;
            heldPiece = currentPiece;
            heldPiece.transform.position = new Vector3(-4, 18, 0);

            // heldPiece.SetActive(false);
            UpdateQueue();
            SpawnPiece();
            heldPiece.GetComponent<Tetrominoes>().inHold = true;
            // currentPiece.transform.position = currentPiece.GetComponent<Tetrominoes>().spawnLocation;
        }
        else { // else swap
            GameObject temp = currentPiece;
            currentPiece = heldPiece;
            heldPiece = temp;

            currentPiece.GetComponent<Tetrominoes>().isCurrentPiece = true;
            currentPiece.GetComponent<Tetrominoes>().inHold = false;
            currentPiece.transform.position = currentPiece.GetComponent<Tetrominoes>().spawnLocation;

            heldPiece.GetComponent<Tetrominoes>().isCurrentPiece = false;
            heldPiece.GetComponent<Tetrominoes>().inHold = true;
            heldPiece.transform.position = new Vector3(-4, 18, 0);
        }
    }


    public void CreateShadow() {
        currentShadow = Instantiate(pieces[numberList[bagSpawnCounter - 1]], new Vector3(4, 20, 0), Quaternion.identity);
        currentShadow.transform.parent = shadowParent.transform;
        currentShadow.GetComponent<Tetrominoes>().isShadow = true;
        currentShadow.name = currentPiece.tag + " Shadow";
        currentShadow.tag = "shadow";
        currentShadow.GetComponent<Tetrominoes>().isCurrentPiece = true;

        foreach(Transform child in currentShadow.transform) {
            child.GetComponent<SpriteRenderer>().color -= new Color(0, 0, 0, 0.5f);
        }
    }


    public void UpdateShadow() {
        int x = Mathf.RoundToInt(currentPiece.transform.position.x);
        int y = Mathf.RoundToInt(currentPiece.transform.position.y);

        bool shadowLanded = false;
        currentShadow.transform.position = new Vector3(x, y, 0);

        while (CheckValidMove(currentShadow) && !shadowLanded) {
            currentShadow.transform.position += Vector3.down;

            if (!CheckValidMove(currentShadow)) {
                shadowLanded = true;
                currentShadow.transform.position += Vector3.up;
            }            
        }       
    }

    IEnumerator WaitOneFrame() {
        yield return new WaitForSeconds(1);
    }
}
