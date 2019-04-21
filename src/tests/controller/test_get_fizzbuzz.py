import unittest

from nose.plugins.attrib import attr
from parameterized import param, parameterized

import run
from server.exceptions import ValidationError
from server.controller import get_fizzbuzz


@attr(size="small")
class TestGetFizzBuzzSmall(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        pass

    @classmethod
    def tearDownClass(cls):
        pass

    def setUp(self):
        pass

    def tearDown(self):
        pass

    @parameterized.expand([
        param("value_1", input=1, expected="1"),
        param("value_2", input=2, expected="2"),
        param("value_3", input=3, expected="Fizz"),
        param("value_4", input=4, expected="4"),
        param("value_5", input=5, expected="Buzz"),
        param("value_6", input=6, expected="Fizz"),
        param("value_10", input=10, expected="Buzz"),
        param("value_15", input=15, expected="FizzBuzz"),
        param("value_30", input=30, expected="FizzBuzz"),
    ])
    def test_fizzbuzz(self, _, input, expected):
        actual = get_fizzbuzz.fizzbuzz(input)
        self.assertEqual(actual, expected)

    @parameterized.expand([
        param("value_1", input="1", expected={"fizzbuzz": "1"}),
    ])
    def test_response(self, _, input, expected):
        actual = get_fizzbuzz.get_response(input)
        self.assertEqual(actual, expected)

    @parameterized.expand([
        param(
            "minus",
            input=-1,
            expected={
                "type": ValidationError,
                "message": [{
                    "code": "E001",
                    "message": "`-1` is invalid value. must be larger than `0`."
                }]
            }
        ),
        param(
            "zero",
            input=0,
            expected={
                "type": ValidationError,
                "message": [{
                    "code": "E001",
                    "message": "`-1` is invalid value. must be larger than `0`."
                }]
            }
        ),
        param(
            "natural number",
            input=1,
            expected={
                "type": AssertionError,
                "message": "no errror"
            }
        ),
    ])
    def test_validate(self, _, input, expected):
        with self.assertRaises(expected["type"], msg=expected["message"]):
            get_fizzbuzz.validate(input)
            self.fail("no errror")


@attr(size="medium")
class TestGetFizzBuzzMedium(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.app = run.app.test_client()
        cls.url = "/v1/fizzbuzz/{n}"

    @classmethod
    def tearDownClass(cls):
        pass

    def test_2xx(self):
        # リクエスト
        url = self.url.format(n=3)
        response = self.app.get(url)

        # 検証
        self.assertEqual(response.status_code, 200)
        response_body = response.get_json()
        self.assertEqual(response_body["fizzbuzz"], "Fizz")

    def test_4xx(self):
        # リクエスト
        url = self.url.format(n=0)
        response = self.app.get(url)

        # 検証
        self.assertEqual(response.status_code, 400)
        response_body = response.get_json()
        self.assertEqual(
            response_body["errors"],
            [{
                "code": "E001",
                "message": "`0` is invalid value. must be larger than `0`."
            }]
        )
