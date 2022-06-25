from cocotb_bus.drivers import Driver

from cocotb.triggers import RisingEdge


def generator_constant(c):
    while True:
        yield c


class AxiDriver(Driver):
    def __init__(self, clk, data, valid, ready, valid_generator):
        super().__init__()
        self.clk = clk
        self.data = data
        self.valid = valid
        self.ready = ready
        self.valid_generator = valid_generator

    async def _driver_send(self, transaction, sync=True, **kwargs):
        clock = RisingEdge(self.clk)

        self.valid.value = 1
        self.data.value = transaction

        await clock
        while not self.ready.value:
            await clock

        self.valid.value = 0
        for _ in range(next(self.valid_generator)):
            await clock
