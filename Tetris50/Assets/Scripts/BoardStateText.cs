using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class BoardStateText : MonoBehaviour
{
    private Text text;
    private Transform[,] boardState;

    // Start is called before the first frame update
    void Start()
    {
        text = GetComponent<Text>();
    }

    // Update is called once per frame
    void Update()
    {
        text.text = "";
        boardState = Board.boardState;
        string state = "";
        for (int i = 0; i < 21; i++) {
            for (int j = 0; j < 10; j++) {
                if (boardState[20-i, j] != null) {
                    state = "True\t";
                }
                else{
                    state = "False\t";
                }

                text.text += state;
            }
            text.text += "\n";
        }
    }
}
