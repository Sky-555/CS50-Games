using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GrabPickups : MonoBehaviour {
	public GameObject player;
	private AudioSource pickupSoundSource;
	public static int CurrentLevel = 1;

	void Awake() {
		pickupSoundSource = DontDestroy.instance.GetComponents<AudioSource>()[1];
	}

	void OnControllerColliderHit(ControllerColliderHit hit) {
		if (hit.gameObject.tag == "Pickup") {
			pickupSoundSource.Play();
			Player.level++;
			SceneManager.LoadScene("Play");
		}
	}

	void Update() {
		CurrentLevel = Player.level;
	}
}
